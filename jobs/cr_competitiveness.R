## Author: 	orlowsma@hu-berlin.de
## Project: Moderate as necessary - The role of electoral competitiveness in 
## 			explaining parties' policy shifts 
## Content: Compute electoral competitiveness at the party level based on 
## 			Orlowski's (2015) insulation values and conditional logit voting models
##			fit on individual level voting data

set.seed(42)

IN <- read.csv("./data/insulation.csv", stringsAsFactors = FALSE)

# Load helper functions to simulate vote shares from conditional logit fits
source("./jobs/fun_SimVoteShares.R")
source("./jobs/fun_KnowledgeDecline.R")

# Wrap function around competitiveness computation to apply to all lower houses 
# in insulation data
GenCompData <- function(lh
						, path_to_clog  = "./data/clogit/"
						, nsim.clg  = 1000
						, knwl_dur  = 3650
						, inflect  = .95
						, hill  = - 8
						, asym  = .25){

	print(lh)

	na.ret <- data.frame(IN[IN$lh_id == lh, ]
						, pty_lhelc_identsh = NA
						, pty_csim_lhvotesh = NA
						, pty_csim_lhvotesh_sd = NA
						, pty_clg_lhvotesh = NA
						, clg_pseudor2 = NA
						, clg_bpid = NA
						, clg_bpid_se = NA
						, csim_disc = NA
						, pty_comp = NA)

	ctr <- unique(IN$ctr_ccode[which(IN$lh_id == lh)])
	lhelc <- unique(IN$lhelc_id[which(IN$lh_id == lh)])
	eyear <- as.POSIXlt(unique(IN$lhelc_date[which(IN$lhelc_id == lhelc)]))$year + 1900

	# Two elections in UK 1974
	if(lhelc %in% c(10009, 10010)){

		eyear <- ifelse(lhelc == 10009, 197402, 197410)
	
	}
	
	# get existing clogit models
    clg_files <- list.files(path_to_clog, tolower(ctr))
  
    clg_years <- unique(as.numeric(sapply(strsplit(clg_files, "_"), function(x) x[2])))

    # Skip election if no conditional logit estimates exist
    if( length(clg_files) == 0 || ! eyear %in% clg_years ){
    
		return(na.ret)
    
    }else{
      
		clg_pred <- read.csv(paste0(path_to_clog, tolower(ctr), "_", eyear, "_predict.csv"))
		clg_vcov <- read.csv(paste0(path_to_clog, tolower(ctr), "_", eyear, "_vcov.csv"))
		timefrom <- as.POSIXlt(unique(IN$lhelc_date[which(IN$lhelc_id == lhelc)]))
      
    }

    timeto <- as.POSIXlt(unique(IN$lhelc_date[which(IN$lhelc_prv_id == lhelc)]))
    
    if(length(timeto) == 0){
      
      return(na.ret)
      
    }

    time_passed <- as.numeric(difftime(timeto, timefrom, unit = "days"))
    discount <-  time_passed/knwl_dur

    discount <- KnowledgeDecline(discount
                                , inflect = inflect
                                , hill = hill
                                , asym = asym)

    # Merge party ids into predictions from conditional logit estimates
    clg_pred <- merge(clg_pred, IN[IN$lh_id == lh, c("pty_id", "pty_abr")]
    				, by.x = "party_id", by.y = "pty_abr", all.x = TRUE)

	# format variance-covariance matrix from conditional logit estimate
	clg_vcov <- clg_vcov[complete.cases(clg_vcov), ]
    names(clg_vcov) <- gsub("_", ".", names(clg_vcov))

    # covariance matrix
    clg_coef <- clg_vcov[1, ]
    # get variance-covariance matrix
    clg_vcov <- clg_vcov[-1, ]

	pty_clg_vote <- try(SimVoteShares(clg.data = clg_pred
									, clg.coef = clg_coef
									, clg.vcov = clg_vcov
									, nsim = nsim.clg
									, disc = discount
									, choice.var = "choice"
									, pty.var = "party_id"
									, ident.var = "nrpid_prop"
									, no.id = "NoID"
									, obs.var = "nobs"
									, pid.ind = "PID"))

    if(class(pty_clg_vote) == "try_error"){

      print("Something is wrong with the clogit stuff for:")
      print(paste0(ctr, ": ", eyear))
      return(na.ret)

    }

    # get cumulative distribution of simulated vote shares
    cdfs <- lapply(pty_clg_vote, ecdf)

    insul <- IN[IN$lh_id == lh, c("pty_lwr_v2", "pty_upr_v2", "pty_abr")]
    cdfs <- cdfs[which(names(cdfs) %in% insul$pty_abr)]
    insul <- insul[match(names(cdfs), insul$pty_abr, nomatch = 0), ]

    # compute competitiveness
    comp <- mapply(function(cdf, lwr, upr) { 1 - cdf(upr) + cdf(lwr) }
    		, cdfs
    		, as.list(insul$pty_lwr_v2)
    		, as.list(insul$pty_upr_v2))

    comp <- data.frame(pty_comp = comp, pty_abr = names(comp))

    # get conditional logit outputs to store in data frame
	tmp <- aggregate(clg_pred$nrpid_prop, list(clg_pred$party_id), unique)
	names(tmp) <- c("pty_abr", "pty_lhelc_identsh")
	
	tmp2 <- data.frame(pty_abr = names(sapply(pty_clg_vote, mean))
					, pty_csim_lhvotesh = sapply(pty_clg_vote, mean)
					, pty_csim_lhvotesh_sd = sapply(pty_clg_vote, sd))
	    
	tmp3 <- aggregate(clg_pred[, c("share", "pseudo")], list(clg_pred$choice), unique)
	names(tmp3) <- c("pty_abr", "pty_clg_lhvotesh", "clg_pseudor2")
	    
	tmp <- merge(tmp, tmp2, by = "pty_abr", all.x = TRUE)
	tmp <- merge(tmp, tmp3, by = "pty_abr", all.x = TRUE)

	tmp <- tmp[-which(tmp$pty_abr == "NoID"), ]
    tmp$clg_bpid <- clg_coef[["PID"]]
    tmp$clg_bpid_se <- sqrt(diag(as.matrix(clg_vcov))[which(names(clg_vcov) == "PID")])
    tmp$csim_disc <- discount

    tmp <- merge(tmp, comp, by = "pty_abr", all.x = TRUE)

    out <- merge(IN[IN$lh_id == lh, ], tmp, by = "pty_abr")

    return(out)
}

CP <- lapply(as.list(unique(IN$lh_id)), GenCompData)

CP <- do.call("rbind", CP)

saveRDS(CP, file = "./data/competitiveness.rds")
