## Author: 	orlowsma@hu-berlin.de
## Project: Moderate as necessary - The role of electoral competitiveness in 
## 			explaining parties' policy shifts 
## Content: Create Figure 1: Components of electoral competitiveness at the party
##			level

x <- seq(0,1,length.out = 100)

pdf(file = "./graphs/theory_comp.pdf", width = 8, height = 4.5)

par(mai = c(1,1,.5,.5))
plot(c(0,1), c(0,4), type = "n"
     , xlab = expression(paste(v[i][","][t + 1]))
     , ylab = "Density"
     , cex.lab = 1.2, axes = TRUE, labels = FALSE)
axis(2, 0:4, as.character(seq(0,.4,.1)), las = 2)
axis(1, seq(0, 1,.2), labels = as.character(seq(0,.25,length.out = 6)))
upper_bound <- .6
lower_bound <- .3
v1 <- .4
cord.x <- seq(upper_bound,1,length.out = 100)
cord.y <- dnorm(cord.x, .5, .125)
polygon(c(cord.x,rev(cord.x)),c(rep(0,100),rev(cord.y)), col = "gray70", border = NA)
cord.x <- seq(0,lower_bound,length.out = 100)
cord.y <- dnorm(cord.x, .5, .125)
polygon(c(cord.x,rev(cord.x)),c(rep(0,100),rev(cord.y)), col = "gray70", border = NA)
lines(c(v1, v1), c(-.1, dnorm(v1, .5, .125)), lwd = 2, lty = 3)
lines(c(lower_bound, lower_bound), c(-.1, dnorm(lower_bound, .5, .125)), lwd = 2, lty = 2)
lines(c(upper_bound, upper_bound), c(-.1, dnorm(upper_bound, .5, .125)), lwd = 2, lty = 2)
lines(x, dnorm(x, .5, .125), lwd = 2, lty = 1)
text(v1, 0, labels = expression(paste(v[i][","][t])), pos = 4, cex = 1.2)

legend("topright", bty = "n"
		, legend = c("Insulation Boundary", "Expectations", "Competitiveness")
		, pch = c(NA, NA, 22),
		, pt.bg = c(NA, NA, "gray70")
		, pt.cex = 3
		, lty = c(2, 1, 0)
		, lwd = c(2, 2, 0)
		, col = c(1, 1, NA))
dev.off()
