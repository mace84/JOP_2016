## Author:	orlowsma@hu-berlin.de
## Project: Moderate as necessary - The role of electoral competitiveness in 
## 			explaining parties' policy shifts 
## Content: Create data set for regression analysis combining competitiveness 
## 			and party positions

# Load competitiveness data
CP <- readRDS("./data/competitiveness.rds")

# generate date variable to merge with party position data
years <- sapply(strsplit(as.character(CP$lhelc_date), "-"), function(x) x[1])
months <- sapply(strsplit(as.character(CP$lhelc_date), "-"), function(x) x[2])
CP$date <- as.numeric(paste(years, months, sep = ""))

# next election date to merge competitiveness arising from one election with
# positional data for subsequent election
TMP <- aggregate(CP[, "date"], by = list(CP$lhelc_prv_id), FUN = unique)
names(TMP) <- c("lhelc_prv_id", "merge_date")
CP <- merge(CP, TMP, by.x = "lhelc_id", by.y = "lhelc_prv_id", all.x = TRUE)

# Competitiveness varies with lower house composition and elections. For some
# cases, this implies two or more competitiveness values arising for each party 
# from one elections (if lower house composition changes during a legislative 
# term due to party splits, each party gets two competitiveness values). Select
# only those values arising from the lower house composition prior to an election.
# Since lower house election ids are ordered temporarrily, this means chosing those
# cases with a higher id.

TMP <- aggregate(CP$lh_id, by = list(CP$lhelc_id), FUN = unique)
keep_lhs <- sapply(TMP$x, function(x) x[which(x == max(x))])
CP <- CP[which(CP$lh_id %in% keep_lhs), ]

# Change German Greens cmp id to account for lag structure in merging with CMP
# data

CP$cmp_id[which(CP$pty_id == 6006 & CP$merge_date == 198701)] <- 41111
CP$cmp_id[which(CP$pty_id == 6006 & CP$merge_date == 199012)] <- 41112
CP$cmp_id[which(CP$pty_id == 6006 & CP$merge_date >= 199410)] <- 41113

# Merge with party positions
MP <- readRDS("./data/lrpos.rds")
DT <- merge(MP, CP[, -which(names(CP) == "date")]
			, by.x = c("party", "date"), by.y = c("cmp_id", "merge_date")
			, all.x = TRUE)

# Drop countries not included in competitiveness data
tmp <- by(DT$pty_comp, DT$country, function(x) ! all(is.na(x)))
DT <- DT[DT$country %in% as.numeric(names(tmp)[which(tmp)]), ]

# Merge with additional data from various sources
AV <- read.csv("./data/addvars.csv")
DT <- merge(DT, AV[, c("pty_id", "lhelc_id", "pty_cab", "tier1_avemag", "leadact")]
			, by = c("lhelc_id", "pty_id"), all.x = TRUE)

write.csv(DT, file = "./data/comp_ppos.csv", row.names = FALSE, na = "")
