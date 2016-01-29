# Replication material 
Abou-Chadi/Orlowski (2016): Moderate as necessary. The Role of Electoral
Competitiveness and Party Size in Explaining Parties' Policy Shifts. _Journal of
Politics_.

## Abstract
This paper investigates how the degree of electoral competition affects parties'
policy positions. It follows a growing body of research on party positioning in
multi-party competition that regards elections as signals for parties that have
to choose their positions and issue strategies. In this article we argue that
previous elections provide information about the competitiveness of the upcoming
election. The expected degree of electoral competition affects parties' future
policy positions since with increasing competitiveness of an election, parties
have higher incentives to move towards a vote-maximizing position. However, what
constitutes a vote-maximizing strategy varies between parties. While large
mainstream parties have an incentive to moderate their positions, small and
niche parties choose more extreme positions to distinguish themselves from their
mainstream competitors. Applying a novel measure of electoral competitiveness,
we find that the degree of electoral competition, indeed, determines parties'
policy shifts, but that this effect is moderated by party size.

## Notes

You can replicate all findings reported in the paper running __an\_compsze.do__
with the working directory set to this replication folder. The do-file draws on
the data set __comp\_ppos.csv__ which contains party-level observations on all
covariates referred to in the paper. See below for a description of all
variables and their sources. The remaining scripts are for computing party-level
competitiveness from raw input data. To generate __comp\_ppos.csv__ from input,
proceed by running the following scripts in order:

1. __cr\_competitiveness.R__  
2. __cr\_lrpos.R__  
3. __cr\_comp\_ppos.R__  

The __fun\_\*.R__ scripts contain helper functions that are called from within
the __cr\_\*.R__ scripts.

The __gr\_\*.R__ scripts draw on the outputs of the analyses stored in
__./report/__. They create the figures reported in the paper which visualize the
results obtained by Stata using `ggplot2`. You need to run __an\_compsze.do__
before you can execute the __gr\_\*.R__ scripts. All graphics are writte to
separate pdf files in __./graphs/__.

If you have any questions, feel free to [contact me](mailto:orlowsma@hu-berlin.de).

### Software 

#### Stata
We used Stata 13 to estimate all models reported in the paper. Two external ados
are called in the corresponding do-file: `cgmreg` and `estout`. `cgmreg` is
available at  [http://gelbach.law.upenn.edu/~gelbach/ado/cgmreg.ado](http://gelb
ach.law.upenn.edu/~gelbac h/ado/cgmreg.ado). You can install `estout` from
within Stata via `net install st0085_2.pkg, from("http://www.stata-
journal.com/software/sj14-2/")`

#### R session info
* R version 3.2.3 (2015-12-10), x86\_64-apple-darwin14.5.0
* Base packages: base, datasets, graphics, grDevices, methods, stats, utils
* Other packages: coda 0.17-1, combinat 0.0-8, ggplot2 1.0.1, MASS 7.3-45, MCMCpack 1.3-3, reshape2 1.4.1
* Loaded via a namespace (and not attached): colorspace 1.2-6, digest 0.6.8,
    grid 3.2.3, gtable 0.1.2, labeling 0.3, lattice 0.20-33, magrittr 1.5,
    munsell 0.4.2, plyr 1.8.3, proto 0.3-10, Rcpp 0.12.2, scales 0.3.0,
    stringi 1.0-1, stringr 1.0.0, tools 3.2.3

## Content

### Data Files 
The data files in __./data/__ are:   

* __addvars.csv__ - Control variables added from different sources (see below)
* ./clogit/__ctr\_yyyy\_predict.csv__ - Several files with predictions from conditional logit estimates. _ctr_ in the file name is the ISO 3166-1 alpha-3 country code and _yyyy_ the four digit election year. See below for content description.
* ./clogit/__ctr\_yyyy\_vcov.csv__ - Several files with coeficient and variance-covariance estimates from conditional logit models on individual level survey data. The first row contains the coefficient estimates, all other rows are the variance-covariance matrix. _ctr_ in the file name is the ISO 3166-1 alpha-3 country code and _yyyy_ the four digit election year.
* __comp\_ppos.csv__ - Party-level data on party-positions, competitiveness and selected covariates
* __insulation.csv__ - Party-level insulation data from Orlowski (2015)


### Computer Code
The source files in __./jobs/__ are:   

* __an\_compsze.do__ - Stata do-file containing all analyses reported in the paper
* __cr\_competitiveness.R__ - R script to compute party-level competitiveness based on Orlowski's (2015) insulation values and results from conditional logit estimates on individual surevey data
* __cr\_comp\_ppos.R__ - R script to generate party-level data set combining competitiveness, party positions, and control variables
* __cr\_lrpos.R__ - R script to compute logit scaled left-right positions from [MARPOR](https://manifestoproject.wzb.eu) data on party manifestos. You need to download a copy of the [2015a data set](https://manifestoproject.wzb.eu/datasets) to run this script.
* __fcts\_logrile.R__ - R script with helper functions to compute log scale left-right positions with standard errors according to [Lowe et al. (2011)](http://onlinelibrary.wiley.com/doi/10.1111/j.1939-9162.2010.00006.x/abstract). The code is largely based on the [replication material provided by the original authors](http://hdl.handle.net/1902.1/17073).
* __fun\_SimVoteShares.R__ - R script with function to compute a set of plausible vote shares for each party based on predicted probabilities from conditional logit fits on individual level survey data
* __fun\_KnowledgeDecline.R__ - R script with function to compute discount factor for information value of survey data on voting intentions depending on time passed since survey
* __fun\_PredictClogit.R__ - R script with function to compute the predicted probability of voting for a party for each party-identifier - party pair based on conditional logit coeficients
* __fun\_SimVoting.R__ - R script with function that simulates an election based on predicted probabilities for different party-identifiers to vote for a particular party
* __fun\_DrawPropVec.R__ - R script with function to generate random vector with proportions that sum up to unity
* __fun\_plotME2.R__ - R script with function to create marginal effects plot from Stata estimation results
* __gr\_theorycomp.R__ - R script to produce Figure 1: Components of electoral competition at the party level
* __gr\_meps.R__ - R script to produce marginal effects plots depicted in Figures 2, 3a, 3b, 4a, 4b, A2, and A3 based on Stata estimation results
* __gr\_clogit\_time.R__ - R script to produce Figure A1: Point-estimates and model fit for conditional logit models regressing vote choice on party ID

## Data Sets

### addvars.csv
| Variable       				| Description 													| External source 					|
|-------------------------------|---------------------------------------------------------------|-----------------------------------|
| _pty\_id_						| Party ID 														| 
| _ctr\_ccode_					| Country code (ISO 3166-1 alpha-3) 							|
| _lhelc\_id_					| Lower house election ID 										|
| _lhelc\_date_					| Lower house election date 									|
| _pty\_cab_					| Dummy = 1 for parties in government prior to election 		|
| _tier1\_avemag_ 				| Average district magnitude at first tier of electoral system 	| [Bormann and Golder (2013)](http://mattgolder.com/elections) |
| _leadact_ 					| Measure for leadership-dominance based on expert surveys 		| [Schumacher et al. (2013)](https://dl.dropboxusercontent.com/u/53910985/WPCP_JOP_data.zip) |

### ctr\_yyyy\_predict.csv

| Variable       	| Description 																			| 
|-------------------|---------------------------------------------------------------------------------------|
| _choice_       	| Abbrevation of potential party choice  												|
| _party\_id_		| Abbrevation of party respondent identifys with										|
| _Phat_			| Predicted probability of respondent identifying with _party\_id_ to vote for _choice_ |
| _nrpid_prop_		| Share of respondents identifying with _party\_id_ 									|
| _nobs_			| Number of respondents in survey with valid information on party id and vote choice	|
| _pseudo_			| Pseudo R2 of conditional logit estimate 												|
| _share_			| Predicted vote share for _choice_ based on conditional logit estimates only 			|

### ctr\_yyyy\_vcov.csv

First row contains point estimates for conditional logit estimates of choice-
specific constants and party identificatin. All other rows contain the
corresponding variance-covariance matrix.

### comp_ppos.csv

| Variable       				| Description 																						| External source 							|
|-------------------------------|---------------------------------------------------------------------------------------------------|-------------------------------------------|
| _lhelc\_id_ 					| ID of the lower house election _from_ which competitivenes is computed 							|											|
| _pty\_id_ 					| Party ID 																							| 											|
| _party_ 						| MARPOR party ID 																					| [MARPOR](https://manifestoproject.wzb.eu) |
| _date_ 						| Election year and month as YYYYMM 																|											|
| _country_  					| MARPOR country ID 																				| [MARPOR](https://manifestoproject.wzb.eu) |
| _countryname_   				| String with country name 																			| [MARPOR](https://manifestoproject.wzb.eu) |
| _edate_ 						| Date of election _for_ which competitivenss is computed 											| 											|
| _partyname_    				| String with party name 																			| [MARPOR](https://manifestoproject.wzb.eu) |
| _parfam_						| Party family 																						| [MARPOR](https://manifestoproject.wzb.eu) |
| _pervote_ 					| Vote share in the election _for_ which competitivenss is computed in percentage points 			| [MARPOR](https://manifestoproject.wzb.eu) |
| _absseat_ 					| The number of lower house seats won in the election _for_ which competitivenss is computed 		| [MARPOR](https://manifestoproject.wzb.eu) |
| _totseats_  					| The total number of lower house seats for the election _for_ which competitivenss is computed 	| [MARPOR](https://manifestoproject.wzb.eu) |
| _rile_ 						| Left-right position based on raw _rile_ scores. Data basis is the manifesto of the election _for_ which competitivenss is computed 	| [MARPOR](https://manifestoproject.wzb.eu) |
| _logrile_ 					| Left-right position based on logit _rile_ scores [Lowe et al. (2011)](http://onlinelibrary.wiley.com/doi/10.1111/j.1939-9162.2010.00006.x/abstract). Data basis is the manifesto of the election _for_ which competitivenss is computed 	| Own calculations based on [MARPOR](https://manifestoproject.wzb.eu) |
| _logrile.SE_ 					| Std. Err. of _logrile_ scores [Lowe et al. (2011)](http://onlinelibrary.wiley.com/doi/10.1111/j.1939-9162.2010.00006.x/abstract). Data basis is the manifesto of the election _for_ which competitivenss is computed 	| Own calculations based on [MARPOR](https://manifestoproject.wzb.eu) |
| _pty\_abr_					| Party abbrevation 																				|											|
| _ctr\_ccode_ 					| Country code (ISO 3166-1 alpha-3) 																|											|
| _lhelc\_date_ 				| Date of election _from_ which competitivenss is computed 											| 											|
| _lh\_id_ 						| ID of the lower house _from_ which competitivenes is computed 									|											|
| _lhelc\_prv\_id_ 				| ID of the lower house election prior to that _from_ which competitivenes is computed 				|											|
| _pty\_lwr\_v2_				| Lower insulation boundary 																		|											|
| _pty\_upr\_v2_				| Upper insulation boundary 																		|											|
| _pty\_lhelc\_identsh_ 		| Share of party identifiers in corresponding post election survey 									|											|
| _pty\_csim\_lhvotesh_ 		| Mean simulated vote share based on conditional logit fits 										|											|
| _pty\_csim\_lhvotesh\_sd_ 	| Std. Dev. of simulated vote shares based on conditional logit fits 								|											|
| _pty\_clg\_lhvotesh_ 			| Vote shares estimate based on conditional logit fit 												|											|
| _clg\_pseudor2_ 				| Pseudo R2 of conditional logit fit 																|											|
| _clg\_bpid_  					| Point estimate of party ID coefficient in conditional logit fit 									|											|
| _clg\_bpid\_se_ 				| Std. Err. of party ID coefficient in conditional logit fit 										|											|
| _csim\_disc_ 					| Discount factor used in vote share computation 													|											|
| _pty\_comp_ 					| Party-level competitiveness value 																|											|
| _pty\_cab_					| Dummy = 1 if party was in government prior to election _for_ which competitiveness is computed 	|
| _tier1\_avemag_ 				| Average district magnitude at first tier of electoral system 										| [Bormann and Golder (2013)](http://mattgolder.com/elections) |
| _leadact_ 					| Measure for leadership-dominance based on expert surveys 											| [Schumacher et al. (2013)](https://dl.dropboxusercontent.com/u/53910985/WPCP_JOP_data.zip) |

### insulation.csv

| Variable       	| Description 						| 
|-------------------|-----------------------------------|
| _pty\_id_       	| Party ID 							|
| _ctr\_ccode_		| Country code (ISO 3166-1 alpha-3) |
| _lhelc\_date_		| Lower house election date 		|
| _lh\_id_			| Lower house composition ID 		|
| _lhelc\_id_		| Lower house election ID 			|
| _lhelc\_prv\_id_	| Previous lower house election ID 	|
| _pty\_lwr\_v2_	| Lower insulation boundary 		|
| _pty\_upr\_v2_	| Upper insulation boundary 		|
| _pty\_abr_		| Party abbrevation 				|
| _cmp\_id_			| MARPOR party ID 					|

## Sources
[Bormann, N. and M. Golder. 2013. Democratic electoral Systems Around the World, 1946-2011. _Electoral Studies_ 32(2): 360-369.](http://mattgolder.com/elections)

[Lowe, W., K. Benoit, S. Mikhaylov, and M. Laver. 2011. Scaling Policy Preferences from Coded Political Texts. _Legislative Studies Quarterly_ 36(1): 123-155.](http://onlinelibrary.wiley.com/doi/10.1111/j.1939-9162.2010.00006.x/abstract)

Orlowski, M. (2015): Linking Votes to Power. Measuring Electoral Competitiveness at the Party Level. Paper presented at the General Conference of the European Politial Science Association,  25-27 June 2015, Vienna.

[Schumacher, G., D. de Vries, and B. Vis. 2013. Why do Parties change Position? Party organization and environmental incentives. _Journal of Politics_, 75(2): 464-477](https://dl.dropboxusercontent.com/u/53910985/WPCP_JOP_data.zip)