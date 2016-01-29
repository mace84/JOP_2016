## Author:  orlowsma@hu-berlin.de
## Project: Moderate as necessary - The role of electoral competitiveness in 
##          explaining parties' policy shifts
## Content: Function that computes simulated vote shares for each party based on
##          conditional logit fits on individual level data, taking into account 
##          the uncertainty in these results and the time passed since the survey.

SimVoteShares <- function(clg.data, clg.coef, clg.vcov
                          , nsim = 1000
                          , disc = 0
                          , ident.var = "ident_prop"
                          , obs.var = "nobs"
                          , choice.var = "choice"
                          , pty.var = "pty_id"
                          , no.id = "NoID"
                          , pid.ind = "PID"){
  ##
  ## This function computes a set of plausible vote shares for each party based 
  ## on predicted probabilities from conditional logit fits on individual level 
  ## survey data, taking to account several sources of uncertainty.
  ##
  ## Dependencies:  MCMCpack
  ##
  ## Args:
  ##      clg.data:   A data frame with information on possible party choices
  ##                  and types of party identifiers used to fit the original 
  ##                  model
  ##
  ##      clg.coef:   A vector with regression coefficients from a conditional 
  ##                  logit model fit
  ##
  ##      clg.vcov:   The variance-covariance matrix of the conditional logit 
  ##                  model fit
  ##
  ##      nsim:       An integer value indicating the number of simulations to
  ##                  run to calculate aggregate vote shares. Default is 1000
  ##
  ##      disc:       A numeric value in the [0,1] interval describing the 
  ##                  information value of survey data on voting intentions 
  ##                  depending on time passed since survey
  ##
  ##      ident.var:  A character or integer value indicating the variable with
  ##                  information on the observed share of party-identifiers for
  ##                  each party in clg.data. Default is 'ident_prop'
  ##
  ##      obs.var:    A character or integer value indicating the variable with
  ##                  information in clg.data on the number of observations from 
  ##                  which the share of party-identifiers was estimated.
  ##                  Default is 'nobs'
  ##
  ##      choice.var: A character or integer value indicating the choice
  ##                  variable in clg.data. Default is 'choice'
  ##
  ##      pty.var:    A character or integer value indicating the party id 
  ##                  variable in clg.data. Default is 'pty_id'
  ##
  ##      no.id:      A value indicating how non-identifiers are coded in 
  ##                  clg.data. Default is 'NoID'
  ##
  ##      pid.ind:    A character or integer value indicating the name or 
  ##                  position of the coefficient for the party-id indicator 
  ##                  variable that was used in the model fit in clg.coef. 
  ##                  Default is 'PID'
  ##
  ## Returns:
  ##      A data frame with plausible vote shares for each party.
  ##
  require(MCMCpack)
  
  deps <- c("PredictClogit", "SimVoting", "DrawPropVec")
  
  if( !all(deps %in% lsf.str()) ){
    
    load <- paste0("./jobs/fun_", deps[! deps %in% lsf.str()]
                   , ".R")
    lapply(as.list(load), source)
    
  }
  
  # get identifier shares
  ident_shares <- c(by(clg.data[[ident.var]], clg.data[[pty.var]], unique))

  # generate variance covariance matrix of proportions 
  n <- unique(clg.data[[obs.var]])
  
  ident_nums <- floor(n*ident_shares)

  share_draw <- rdirichlet(nsim, ident_nums)
  
  # create data frame list for election simulation
  share_draw <- apply(share_draw, 1, function(x){
    
                                      df <- data.frame(a = names(ident_shares)
                                                      , b = x)
                                      names(df) <- c(pty.var, ident.var)
                                      df
                                      }
                      )
  
  # draw coefficients
  coefs <- mvrnorm(nsim, as.numeric(clg.coef), clg.vcov)
  colnames(coefs) <- names(clg.coef)
  
  # if negative coefficients are drawn randomly, these are set to 0
  coefs <- apply(coefs, 2, function(x){ x[x < 0] <- 0; x})
  
  base_asc <- names(clg.coef)[which(clg.coef == 0)]
  # make the prediction
  preds <- apply(coefs, 1, function(x) PredictClogit(x
                                                    , clg.data   = clg.data
                                                    , base.asc = base_asc
                                                    , choice.var = choice.var
                                                    , pty.var    = pty.var
                                                    , no.id      = no.id
                                                    , pid.ind    = pid.ind))
  
  
  preds <- mapply(function(x, y) merge(x, y, by = pty.var, all.x = TRUE)
                  , preds, share_draw, SIMPLIFY = FALSE)
  
  voteshares <- sapply(preds, SimVoting
                       , pty.var    = pty.var
                       , ident.var  = ident.var
                       , choice.var = choice.var)
  voteshares <- t(voteshares)
  
  if(disc > 0){

    np <-  ncol(voteshares)
    random <- rdirichlet(nsim, rep(1, np))
    # add random vote shares according to discount factor
    voteshares <- (disc * random) + ((1-disc)*voteshares)
    
  }
  
  out <- data.frame(voteshares)
  
  return(out)

}
