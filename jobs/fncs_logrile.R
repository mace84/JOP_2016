## Author:  orlowsma@hu-berlin.de
## Project: Moderate as necessary. the role of electoral competitiveness in
##          explaining parties' policy shifts
## Content: Functions to compute logit scale left-right positions with standard 
##          errors from Manifesto Project data.
##          The code is originally provided by Ken Benoit in the replication 
##          material for Lowe et al. 2011 at http://hdl.handle.net/1902.1/17073
##          The functions are simplified here for logit scale use only.

AggrCat <- function(charlist, cmprow){

  temparray <- cmprow[, charlist[1]]
  
  if( length(charlist) > 1 ){
      
      for( i in 2:length(charlist) ){
          
      temparray <- temparray + cmprow[,charlist[i]]
    }
  }
    
    return(temparray)
}

LogRL <- function(cmpdata, charlist.R, charlist.L, offset = .5){
  
  R <- AggrCat(charlist.R, cmpdata)
  L <- AggrCat(charlist.L, cmpdata)

  out <- log((R+offset)/(L+offset))
  
  return(out)

}

MkImp <- function(cmpdata, charlist.R, charlist.L, n = 100, offset = .5){

  R <- AggrCat(charlist.R, cmpdata)
  L <- AggrCat(charlist.L, cmpdata)
  
  out <- log((R+L+(offset*2))/n)

  return(out)
}


CmpSE <- function(cmprow
				, replicates = 100
				, charlist.L = NULL
				, charlist.R = NULL
				, offset = 0.5
        , ttl = 1) {
	
    require(combinat)
    
    if(is.character(ttl)){

      ttl_idx <- which(names(cmprow) == ttl) 

    }else if(is.numeric(ttl)){

      ttl_idx <- ttl

    }else{

      stop("Provide a valid argument indicating the column with total manifesto length.")
    
    }
    
    if( is.null(charlist.L) & is.null(charlist.R) ){
        
          stop("Must specify at least L and R; make charlist.L=NA if only added per categories like markeco")
      
    }

  	p <- matrix(cmprow[-ttl_idx]/100, nrow = 1)
  	n <- as.numeric(cmprow[ttl_idx])
  	
  	if( is.na(n) ){

  		n <- 200
  		# KB: "fix to something closed to the overall mean if n==NA to stop it breaking
  		# 	  if this is one of those "all missing" rows, return vector of NAs for per categories if "none" 
  		# 	  or just a single NA if one of the specific variables and one of the Lowe et al types"
  	}
  	
  	if( all(is.na(cmprow)) ){

  			return(NA)

  	}
  	
  	tempdraw <- rmultinomial(rep(n, replicates), p)/n*100
    colnames(tempdraw) <- names(cmprow)[-ttl_idx]

  	if( is.na(charlist.L[1]) ){
  		
  			L <- 0
  	  
  	}else{
  	  	
  			L <- AggrCat(charlist.L, tempdraw)
  	  
  	}
    
    R <- AggrCat(charlist.R, tempdraw)

  	offsetrescaled <- offset / n * 100  # because we are using %s not Ns
  	      	
  	out <- sd(log((R+offsetrescaled)/(L+offsetrescaled)))
  	
  	return(out)
}