## Matthias Orlowski
## Project: Moderate as necessary - The role of electoral competitiveness in 
## 			explaining parties' policy shifts 
## Content: Function to create marginal effects plot from stata results

plotME2 <- function(res, rng, const1 = "v_dcomp", iaterm = "v_compsize"){

	require(ggplot2)

	Z <- seq(min(rng), max(rng), length.out = 100)
	b <- res[1, ]
	Vcov <- as.matrix(res[- 1, ])
	rownames(Vcov) <- colnames(Vcov)

	conb <- b[[const1]] + b[[iaterm]]*Z
	conse <- sqrt(Vcov[const1,const1] + Vcov[iaterm,iaterm]*(Z^2) + 2*Z*Vcov[const1,iaterm])
	
	lower95.ci <- conb + 1.96*conse
	upper95.ci <- conb - 1.96*conse

	Pdat <- data.frame(Z, conb, upper95.ci, lower95.ci)

	# create plot
	mep <- ggplot(Pdat, aes(x = Z, y = conb))
	mep <- mep + geom_ribbon(aes(ymin=lower95.ci, ymax = upper95.ci)
                                     , data = Pdat, colour = NA
                                     , fill = "gray70")
	mep <- mep + geom_hline(yintercept = 0, linetype = 3)
	mep <- mep + geom_line(colour = "black") 
	mep <- mep + theme_bw() + theme(panel.grid = element_blank())
	RUGD <- data.frame(x = as.numeric(rng[[1]]), conb = as.numeric(0))
	mep <- mep + geom_rug(aes(x, conb), data = RUGD, sides = "b"
						, position = position_jitter(width = .001, height = .001)
                        , colour = "gray70")

	mep <- mep + labs(x = "Const"
                    , y = expression(frac(paste(partialdiff , "Moderation")
                                          , paste(partialdiff, Delta, "Competitiveness"))))


	return(mep)

}