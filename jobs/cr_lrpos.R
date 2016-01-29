## Author:	orlowsma@hu-berlin.de
## Project:	Moderate as necessary. the role of electoral competitiveness in
## 			explaining parties' policy shifts
## Content:	Generate logit scaled left-right positions with standard errors 
## 			based on Manifest Project data 2015a following Lowe et al. 2011
## Source:	https://manifestoproject.wzb.eu/datasets
##    		You nee to get a copy of the MPDataset_MPDS2015a.csv from the MARPOR
## 			website to run this script


MP <- read.csv("~/Dropbox/Uni/Data/Manifesto/MPDataset_MPDS2015a.csv") # Get data from MARPOR website

source("./jobs/fncs_logrile.R")

set.seed(42)

# Compute uncoded percentages where necessary
per_cats <- names(MP)[grepl("per[1-9]", names(MP))]
MP$peruncod[is.na(MP$peruncod)] <- 100 - rowSums(MP[is.na(MP$peruncod), per_cats], na.rm = TRUE)
MP$peruncod <- sapply(as.list(MP$peruncod), function(x) max(x,0))

# remove misisngs
# replace missings with zero to compute standard errors
MP <- data.frame(MP[-which(names(MP) %in% per_cats)]
				, sapply(MP[, per_cats], function(x) {x[is.na(x)] <- 0; x}))

MP[MP$peruncod == 100, per_cats] <- NA
MP$peruncod[MP$peruncod == 100] <- NA

#### Compute Lowe et al 2011 logit scales and standard errors

rescaledoffset <- 0.5 / MP$total * 100
rescaledoffset[is.na(MP$total)] <- 0.5 / 200 * 100

r_cat <- c("per104", "per201", "per203", "per305", "per401", "per402", "per407"
			, "per414", "per505", "per601", "per603", "per605", "per606")
l_cat <- c("per103", "per105", "per106", "per107", "per202", "per403", "per404"
			, "per406", "per412", "per413", "per504", "per506", "per701")

MP$logrile <- LogRL(MP, r_cat, l_cat, offset = rescaledoffset)

MP$logrile.SE <- apply(MP[, c(per_cats, "peruncod", "total")]
						, 1
						, CmpSE
						, replicates = 1000
						, charlist.L = l_cat
						, charlist.R = r_cat
						, ttl = "total")
MP <- MP[, c("country", "countryname", "edate", "date", "party", "partyname", "parfam"
			, "pervote", "absseat", "totseats", "rile", "logrile", "logrile.SE")]

saveRDS(MP, file = "./data/lrpos.rds")
