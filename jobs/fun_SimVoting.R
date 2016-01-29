## Author:  orlowsma@hu-berlin.de
## Project: Moderate as necessary - The role of electoral competitiveness in 
##          explaining parties' policy shifts
## Content: Function to simulate one election as a draw from a multinomial 
##          distribution for each type of party-identifier. The probabilitiy
##          parameters are based on predicted probabilities for each type of 
##          identifier to vote for each party based on a conditional logit model.

SimVoting <- function(pred.data
                      , pty.var = "pty_id"
                      , ident.var = "ident_prop"
                      , choice.var = "choice"){
  ##
  ## This function simulates an election based on predicted probabilities for
  ## different party-identifiers to vote for a particular party.
  ##
  ## Args:
  ##      pred.data:  A data frame with predicted probabilities for possible 
  ##                  party choices for all types of party identifiers based on
  ##                  a conditional logit model fit
  ##
  ##      pty.var:    A character or integer value indicating the party id 
  ##                  variable in clg.data. Default is 'pty_id'
  ##
  ##      ident.var:  A character or integer value indicating the variable with
  ##                  information on the observed share of party-identifiers for
  ##                  each party in pred.data. Default is 'ident_prop'
  ##
  ##      choice.var: A character or integer value indicating the choice
  ##                  variable in pred.data. Default is 'choice'
  ##
  ## Returns:
  ##      A named vector with simulated vote shares for each party
  ##
  v_types <- aggregate(pred.data[[ident.var]], list(pred.data[[pty.var]])
                          , unique)
  voter_types <- round(v_types$x*1000, 0)
  names(voter_types) <- v_types$Group.1
  
  vote_shares <- NULL
  length(vote_shares) <- length(voter_types)
    
  pred.data <- pred.data[order(pred.data[[ident.var]], pred.data[[pty.var]]), ]
  
  # simulate a single election as draw from  a multinomial distribution
  sim_elc <- lapply(as.list(v_types$Group.1)
                    , function(pid){
                        e <- rmultinom(1
                                       , voter_types[names(voter_types) == pid]
                                       , pred.data$fit[pred.data[[pty.var]] 
                                                       == pid])
                        rownames(e) <- pred.data[[choice.var]][pred.data[[pty.var]]
                                                            == pid]
                        e
                      }
                    )
    
  sim_elc <- do.call(cbind, sim_elc)
    
  out <- rowSums(sim_elc)/sum(rowSums(sim_elc))
  
  return(out)
  
}
