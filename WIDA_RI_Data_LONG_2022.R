#####################################################################################
###
### Data prep script for 2022 WIDA RI data
###
#####################################################################################

### Load packages
require(data.table)
require(SGP)
require(foreign)

### Utility functions
strhead <- function (s, n) {
    if (n < 0)
        substr(s, 1, nchar(s) + n)
    else substr(s, 1, n)
}

### Load data
WIDA_RI_Data_LONG_2022 <- as.data.table(read.spss("Data/Base_Files/2022ACCESSwDemo.sav"))


### Clean up Data
variables.to.keep <- c("DistrictName", "DistrictNumber", "SchoolNumber", "SchoolName", "StateStudentID", "CompositeOverallScaleScore", "CompositeOverallProficiencyLevel", "Grade", "Gender", "EthnicityHispanicLatino", "RaceAmericanIndianAlaskanNative", "RaceAsian", "RaceBlackAfricanAmerican", "RacePacificIslanderHawaiian", "RaceWhite", "LengthofTimeinLEPELLProgram", "IEPStatus")
WIDA_RI_Data_LONG_2022 <- WIDA_RI_Data_LONG_2022[,variables.to.keep, with=FALSE]

old.names <- c("DistrictName", "DistrictNumber", "SchoolNumber", "SchoolName", "StateStudentID", "CompositeOverallScaleScore", "CompositeOverallProficiencyLevel", "Grade", "Gender", "EthnicityHispanicLatino", "RaceAmericanIndianAlaskanNative", "RaceAsian", "RaceBlackAfricanAmerican", "RacePacificIslanderHawaiian", "RaceWhite", "LengthofTimeinLEPELLProgram", "IEPStatus")
new.names <- c("DISTRICT_NAME", "DISTRICT_NUMBER", "SCHOOL_NUMBER", "SCHOOL_NAME", "ID", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL", "GRADE", "GENDER", "HISPANIC_LATINO", "INDIAN_ALASKAN_NATIVE", "ASIAN", "BLACK", "HAWAIIAN_PI", "WHITE", "LENGTH_TIME_ELL_PROGRAM", "IEP_STATUS")
setnames(WIDA_RI_Data_LONG_2022, old.names, new.names)

### Tidy up variables
WIDA_RI_Data_LONG_2022[,DISTRICT_NAME:=as.factor(DISTRICT_NAME)]
setattr(WIDA_RI_Data_LONG_2022$DISTRICT_NAME, "levels", as.character(sapply(levels(WIDA_RI_Data_LONG_2022$DISTRICT_NAME), capwords)))
WIDA_RI_Data_LONG_2022[,DISTRICT_NAME:=as.character(DISTRICT_NAME)]
WIDA_RI_Data_LONG_2022[,SCHOOL_NAME:=as.factor(SCHOOL_NAME)]
setattr(WIDA_RI_Data_LONG_2022$SCHOOL_NAME, "levels", as.character(sapply(levels(WIDA_RI_Data_LONG_2022$SCHOOL_NAME), capwords)))
WIDA_RI_Data_LONG_2022[,SCHOOL_NAME:=as.character(SCHOOL_NAME)]
WIDA_RI_Data_LONG_2022[,ACHIEVEMENT_LEVEL_ORIGINAL:=as.character(ACHIEVEMENT_LEVEL_ORIGINAL)]
WIDA_RI_Data_LONG_2022[,ACHIEVEMENT_LEVEL:=strhead(ACHIEVEMENT_LEVEL_ORIGINAL, 1)]
WIDA_RI_Data_LONG_2022[!is.na(ACHIEVEMENT_LEVEL), ACHIEVEMENT_LEVEL:=paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_RI_Data_LONG_2022[,GRADE:=as.character(GRADE)]

WIDA_RI_Data_LONG_2022[, GENDER:=fcase(
                    GENDER=="F", "Female",
                    GENDER=="M", "Male",
                    GENDER=="", as.character(NA))]

WIDA_RI_Data_LONG_2022[,ETHNICITY:=as.character(NA)]
WIDA_RI_Data_LONG_2022[WHITE=="Y", ETHNICITY:="White"]
WIDA_RI_Data_LONG_2022[HISPANIC_LATINO=="Y", ETHNICITY:="Hispanic or Latino"]
WIDA_RI_Data_LONG_2022[INDIAN_ALASKAN_NATIVE=="Y", ETHNICITY:="American Indian or Alaskan Native"]
WIDA_RI_Data_LONG_2022[ASIAN=="Y", ETHNICITY:="Asian"]
WIDA_RI_Data_LONG_2022[BLACK=="Y", ETHNICITY:="African American"]
WIDA_RI_Data_LONG_2022[HAWAIIAN_PI=="Y", ETHNICITY:="Hawaiian or Pacific Islander"]

WIDA_RI_Data_LONG_2022[,c("HISPANIC_LATINO", "INDIAN_ALASKAN_NATIVE", "ASIAN", "BLACK", "HAWAIIAN_PI", "WHITE"):=NULL]

WIDA_RI_Data_LONG_2022[, IEP_STATUS:=fcase(
                    IEP_STATUS=="Y", "IEP Status: Yes",
                    is.na(IEP_STATUS), "IEP Status: No")]

WIDA_RI_Data_LONG_2022[,YEAR:="2022"]
WIDA_RI_Data_LONG_2022[,CONTENT_AREA:="READING"]
WIDA_RI_Data_LONG_2022[,VALID_CASE:="VALID_CASE"]

### Final tidy up
setcolorder(WIDA_RI_Data_LONG_2022, c("VALID_CASE", "CONTENT_AREA", "YEAR", "GRADE", "ID", "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "ACHIEVEMENT_LEVEL_ORIGINAL", "SCHOOL_NUMBER", "SCHOOL_NAME", "DISTRICT_NUMBER", "DISTRICT_NAME", "GENDER", "LENGTH_TIME_ELL_PROGRAM", "IEP_STATUS", "ETHNICITY"))
setkey(WIDA_RI_Data_LONG_2022, VALID_CASE, CONTENT_AREA, YEAR, ID, SCALE_SCORE)
setkey(WIDA_RI_Data_LONG_2022, VALID_CASE, CONTENT_AREA, YEAR, ID)
WIDA_RI_Data_LONG_2022[which(duplicated(WIDA_RI_Data_LONG_2022, by=key(WIDA_RI_Data_LONG_2022)))-1, VALID_CASE := "INVALID_CASE"]

### Save results
save(WIDA_RI_Data_LONG_2022, file="Data/WIDA_RI_Data_LONG_2022.Rdata")
