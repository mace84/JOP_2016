## Author:  orlowsma@hu-berlin.de
## Project: Moderate as necessary - The role of electoral competitiveness in 
##          explaining parties' policy shifts
## Content: Function to generate random vector with proportions that sum up to 
##          unity

DrawPropVec <- function(len){
  ##
  ## This function generates a vector with random numbers in the (0,1) interval
  ## which sums up to 1.
  ##
  ## Args:
  ##      len:  An integer value specifying the length of the desired output
  ##            vector
  ##
  ## Returns:
  ##      A numeric vector with random values from the c(0,1) interval that
  ##      sum op to 1
  ##
  draws <- rep(NA, len)
  rem <- 1
  
  for(i in 1:len){
    
    if(i != len){
      
      draws[i] <- runif(1, 0, rem)
      rem <- rem - draws[i]
      
    }else{
      
      draws[i] <- rem
      
    }
  }
  
  out <- draws[sample(1:len, len)]
    
  return(out)
  
}
