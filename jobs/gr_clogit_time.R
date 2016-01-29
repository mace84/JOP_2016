## Matthias Orlowski
## Project: Moderate as necessary - The role of electoral competitiveness in 
## 			explaining parties' policy shifts 
## Content: Create Figure A1 with point-estimates and model fit for conditional 
## 			logit models regressing vote choice on party ID 

library(ggplot2)

DT <- read.csv("./data/comp_ppos.csv", stringsAsFactors=FALSE, fileEncoding="Latin1")
DT <- DT[DT$ctr_ccode != "", ]
DT$edate <- as.Date(DT$edate, format = "%d/%m/%Y")

DT <- DT[order(DT$ctr_ccode, DT$edate, DT$pty_id), ]
EL <- aggregate(DT[, c("clg_pseudor2", "clg_bpid")], by = list(DT$ctr_ccode, DT$edate), FUN = mean, na.rm = TRUE)
names(EL)[1:2] <- c("ctr_ccode", "edate")
EL$clg_or <- exp(EL$clg_bpid)

p <- ggplot(EL[EL$ctr_ccode != "USA", ], aes(edate, clg_bpid))
p <- p + geom_point(aes(size = clg_pseudor2)) + facet_grid(ctr_ccode ~ .) 
p <- p + geom_smooth(method = "lm", colour = "black")
p <- p + labs(x = "", y = "Coefficient estimate for party identification")
p <- p + theme_bw() + theme(panel.grid = element_blank())
p <- p + scale_size_continuous(name = expression(paste("Pseudo R"^2)))

pdf(file = "./graphs/clogit_time.pdf", width = 6.5, height = 6.5)
p
dev.off()
