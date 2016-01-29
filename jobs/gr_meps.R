## Matthias Orlowski
## Project: Moderate as necessary - The role of electoral competitiveness in 
## 			explaining parties' policy shifts 
## Content: Create all marginal effects plots
## Notes:	You have to run the analyses in an_comp_sze.do in Stata 
##			prior to running this script

library(reshape2)
library(ggplot2)

source("./jobs/fun_plotME2.R")

# marginal effects plots for all models with interaction of two continuous variables

for(m in c("m2", "mr1", "mr2", "m_activ1", "m_activ3")){
	print(m)
	mr <- read.csv(paste("./report/", m, "_vcov.csv", sep = ""))
	tmp <- ifelse(m == "m_activ3", "_erange", "_vrange")
	mr_rng <- read.csv(paste("./report/", m, tmp, ".csv", sep = ""))
	mr <- mr[apply(mr, 1, function(x) !all(is.na(x))), ]
	
	if(m == "m_activ1"){

		ia_n <-	"v_compsze"
	
	}else if(m == "m_activ3"){

		ia_n <- "v_compextr"

	}else{

		ia_n <-	"v_compsize"
	
	}

	mep <- plotME2(mr, mr_rng, iaterm = ia_n)

	tmp <- ifelse(m == "m_activ3", "Avg. Extremism", "Party Size")
	mep <- mep + labs(x = tmp)
	pdf(file = paste0("./graphs/mep_", m, ".pdf"), width = 6.5, height = 4)
	print(mep)
	dev.off()

}

# Marginal effects for models with competitiveness/niche or large party interaction
for( m in c("mr3", "m_activ2")){
	print(m)
	mr <- read.csv(paste("./report/", m, "_vcov.csv", sep = ""))
	mr <- mr[apply(mr, 1, function(x) !all(is.na(x))), ]
	b <- mr[1, ]
	vcm <- as.matrix(mr[-1,])
	rownames(vcm) <- colnames(vcm)
	z <- c(0,1)
	ia_n <- ifelse(m == "m_activ2", "v_compnche", "v_complargep")
	conb <- b[["v_dcomp"]] + b[[ia_n]]*z
	conse <- sqrt(vcm["v_dcomp","v_dcomp"] + vcm[ia_n,ia_n]*(z^2) + 2*z*vcm["v_dcomp",ia_n])
	lwr <- conb + 1.96*conse
	upr <- conb - 1.96*conse
	Pdat <- data.frame(z, conb, upr, lwr)
	x_bnd <- max(abs(c(Pdat$lwr, Pdat$upr)))
	if(m == "m_activ2"){

		lab_n <- c("Non-Niche Party", "Niche Party")
	

	}else{

		lab_n <- c("Small Party", "Large Party")
	
	}
	
	mep <- ggplot(Pdat, aes(x = conb, y = as.factor(z)))
	mep <- mep + geom_vline(xintercept = 0, linetype = 3, size = 1)
	mep <- mep + geom_errorbarh(aes(xmin = lwr, xmax = upr, width = .1)) + geom_point(size = 3)
	mep <- mep + theme_bw() + theme(panel.grid = element_blank())
	mep <- mep + scale_y_discrete(labels = lab_n)
	mep <- mep + scale_x_continuous(limits=c(-x_bnd, x_bnd))
	mep <- mep + labs(y = "", x = expression(frac(paste(partialdiff, "Moderation")
												, paste(partialdiff, Delta, "Competitiveness"))))
	mep <- mep + theme(axis.text.y = element_text(size = 12))
	
	pdf(file = paste("./graphs/mep_", m, ".pdf", sep = ""), width = 6.5, height = 4)
	print(mep)
	dev.off()


}
