## Author:  orlowsma@hu-berlin.de
## Project: Moderate as necessary - The role of electoral competitiveness in 
##          explaining parties' policy shifts
## Content: Function that descibes the decline of information value of survey 
##          data on voting intentions when predicting future election outcomes.

KnowledgeDecline <- function(x, inflect = .95, hill = - 15, asym = .25){
  ##
  ## This function is a three-parameter logistic function to descibe the 
  ## discount factor with which the information on voting intentions is
  ## discounted when predicting future election outcomes as a function
  ## of time passed since the last election.
  ## 
  ## Args:
  ##      x:        A numeric value in the (0,1) interval describing the time 
  ##                passed since the last electon
  ##      inflect:  A numeric value in (0,1) giving the inflection point of the
  ##                sigmoid-curve describing the relationship between x and the
  ##                discount factor. Default is .95
  ##      hill:     A numeric value giving the hill-slope of the sigmoid-curve 
  ##                describing the relationship between x and the discount 
  ##                factor. Default is -15
  ##      asym:     A numeric value giving the asymmetry factor of the
  ##                sigmoid-curve describing the relationship between x and the 
  ##                discount factor. Default is .25
  ## Returns:
  ##     A numeric value to be interpreted as the discount factor with which the 
  ##     information on voting intentions is discounted when predicting future 
  ##     election outcomes as a asymmetrix sigmoid function of time passed since
  ##     the last election rescaled to the (0,1) interval.
  
  out  <- (1/(1+(x/inflect)^hill)^asym)
  
  return(out)
  
}
