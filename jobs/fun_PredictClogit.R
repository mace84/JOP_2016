## Author:  orlowsma@hu-berlin.de
## Project: Moderate as necessary - The role of electoral competitiveness in 
##          explaining parties' policy shifts
## Content: Function to calculate predicted probabilities for a vector of
##          regression coefficients of a conditional logit model. For each
##          party-identifier - party pair, the predicted probability of
##          voting for the party is calculated.

PredictClogit <- function(clg.coef, clg.data
                          , base.asc
                          , choice.var = "choice"
                          , pty.var = "party_id"
                          , no.id = "NoID"
                          , pid.ind = "PID"){
  ##
  ## This function calculates predicted probabilities for a vector of regression
  ## coefficients for a conditional logit model. For each party-identifier 
  ## - party pair generated from the input data, the predicted probability of
  ## voting for the respective party is calculated.
  ##
  ## Args:
  ##      clg.coef:   A vector with regression coefficients for a conditional 
  ##                  logit fit
  ##
  ##      clg.data:   A data frame with information on possible party choices
  ##                  and types of party identifiers used to fit the original 
  ##                  model
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
  ##      A data frame with all combinations of party-identifiers and 
  ##      party-choice pairs indicating the predicted probability of the 
  ##      identifier type to opt for the respective choice.
  ##
  
  # prepare data for predictions
  pdat <- expand.grid(unique(clg.data[[pty.var]][clg.data[[pty.var]] != no.id])
                      , unique(clg.data[[pty.var]])
                      , stringsAsFactors = FALSE)
  names(pdat) <- c(choice.var, pty.var)
  
  # generate alternative specific constants
  cnst <- matrix(rep(0, nrow(pdat)*(length(clg.coef)-1)), nrow = nrow(pdat))
  choices <- names(clg.coef)[-which(names(clg.coef) == pid.ind)]
  colnames(cnst)  <- choices
  
  pdat <- cbind(pdat, cnst)
  
  for(asc in choices){
    
    pdat[pdat[[choice.var]] == asc, asc] <- 1
    
  }
  
  # generate party id indicator
  pdat[[pid.ind]] <- 0
  pdat[[pid.ind]][pdat[[choice.var]] == pdat[[pty.var]]] <- 1
  
  # exclude base category
  clg.coef <- clg.coef[- which(names(clg.coef) == base.asc)]

  # order coefficients and prediction data
  clg.coef <- clg.coef[order(names(clg.coef))]
  pdat <- pdat[, c(choice.var, pty.var, names(clg.coef))]
  
  # calculate predictions for each case
  pdat$fit <- c(
    sapply(as.list(unique(pdat[[pty.var]])), function(pid){
      dt <- as.matrix(pdat[pdat[[pty.var]] == pid
                           , - which(names(pdat) %in% c(choice.var, pty.var))])
      apply(dt, 1, function(r){
        exp(as.numeric(clg.coef) %*% r)/sum(apply(dt, 1, function(x) exp(as.numeric(clg.coef) %*% x)))
      })
    })
  )
  
  pdat <- pdat[, c(choice.var, pty.var, "fit")]
  
  return(pdat)
}
