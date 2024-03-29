##########################################################################################
###
### Script for calculating SGPs for 2021-2022 WIDA/ACCESS Rhode Island
###
##########################################################################################

### Load SGP package
require(SGP)


### Load Data
load("Data/WIDA_RI_SGP.Rdata")
load("Data/WIDA_RI_Data_LONG_2022.Rdata")

###   Add single-cohort baseline matrices to SGPstateData
SGPstateData <- SGPmatrices::addBaselineMatrices("WIDA_RI", "2022")
#SGPstateData <- SGPmatrices::addBaselineMatrices("WIDA", "2022", "WIDA_RI")

### Run analyses
WIDA_RI_SGP <- updateSGP(
		WIDA_RI_SGP,
		WIDA_RI_Data_LONG_2022,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP", "visualizeSGP", "outputSGP"),
		sgp.percentiles=TRUE,
		sgp.projections=TRUE,
		sgp.projections.lagged=TRUE,
		sgp.percentiles.baseline=TRUE,
		sgp.projections.baseline=TRUE,
		sgp.projections.lagged.baseline=TRUE,
		get.cohort.data.info=TRUE,
		sgp.target.scale.scores=TRUE,
		plot.types=c("growthAchievementPlot", "studentGrowthPlot"),
		sgPlot.demo.report=TRUE,
		parallel.config=list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=4, BASELINE_PERCENTILES=4, PROJECTIONS=4, LAGGED_PROJECTIONS=4, SGP_SCALE_SCORE_TARGETS=4, GA_PLOTS=1, SG_PLOTS=1)))


### Save results
save(WIDA_RI_SGP, file="Data/WIDA_RI_SGP.Rdata")
