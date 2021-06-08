##########################################################################################
###
### Script for calculating SGPs for 2011 to 2016 for WIDA/ACCESS RI
###
##########################################################################################

### Load SGP package

require(SGP)


### Load Data

load("Data/WIDA_RI_Data_LONG.Rdata")


### Run analyses

WIDA_RI_SGP <- abcSGP(
		WIDA_RI_Data_LONG,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP", "visualizeSGP", "outputSGP"),
		sgp.percentiles=FALSE,
		sgp.projections=FALSE,
		sgp.projections.lagged=FALSE,
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
