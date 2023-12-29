#####################################################################################
###
### Data prep script for 2023 WIDA RI data
###
#####################################################################################

### Load packages
require(data.table)
require(SGP)

### Load data
WIDA_RI_Data_LONG_2023 <- fread("Data/Base_Files/RI_Summative_StudRR_File_2023-06-21.csv")


### Clean up Data
variables.to.keep <- c("District Name", "District Number", "School Number", "School Name", "State Student ID", "Scale Score - Overall", "Proficiency Level - Overall", "Grade", "Gender", "Ethnicity - Hispanic/Latino", "Race - American Indian/Alaskan Native", "Race - Asian", "Race - Black/African American", "Race - Pacific Islander/Hawaiian", "Race - White", "Length of Time in LEP/ELL Program", "IEP Status")
WIDA_RI_Data_LONG_2023 <- WIDA_RI_Data_LONG_2023[,variables.to.keep, with=FALSE]

old.names <- c("District Name", "District Number", "School Number", "School Name", "State Student ID", "Scale Score - Overall", "Proficiency Level - Overall", "Grade", "Gender", "Ethnicity - Hispanic/Latino", "Race - American Indian/Alaskan Native", "Race - Asian", "Race - Black/African American", "Race - Pacific Islander/Hawaiian", "Race - White", "Length of Time in LEP/ELL Program", "IEP Status")
new.names <- c("DISTRICT_NAME", "DISTRICT_NUMBER", "SCHOOL_NUMBER", "SCHOOL_NAME", "ID", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL", "GRADE", "GENDER", "HISPANIC_LATINO", "INDIAN_ALASKAN_NATIVE", "ASIAN", "BLACK", "HAWAIIAN_PI", "WHITE", "LENGTH_TIME_ELL_PROGRAM", "IEP_STATUS")
setnames(WIDA_RI_Data_LONG_2023, old.names, new.names)

### Tidy up variables
WIDA_RI_Data_LONG_2023[,DISTRICT_NAME:=as.factor(DISTRICT_NAME)]
setattr(WIDA_RI_Data_LONG_2023$DISTRICT_NAME, "levels", as.character(sapply(levels(WIDA_RI_Data_LONG_2023$DISTRICT_NAME), capwords)))
WIDA_RI_Data_LONG_2023[,DISTRICT_NAME:=as.character(DISTRICT_NAME)]
WIDA_RI_Data_LONG_2023[,SCHOOL_NAME:=as.factor(SCHOOL_NAME)]
setattr(WIDA_RI_Data_LONG_2023$SCHOOL_NAME, "levels", as.character(sapply(levels(WIDA_RI_Data_LONG_2023$SCHOOL_NAME), capwords)))
WIDA_RI_Data_LONG_2023[,SCHOOL_NAME:=as.character(SCHOOL_NAME)]
WIDA_RI_Data_LONG_2023[,SCHOOL_NUMBER:=strtail(paste0("000", SCHOOL_NUMBER), 5)]
WIDA_RI_Data_LONG_2023[,ACHIEVEMENT_LEVEL_ORIGINAL:=as.character(ACHIEVEMENT_LEVEL_ORIGINAL)]
WIDA_RI_Data_LONG_2023[,ACHIEVEMENT_LEVEL:=strhead(ACHIEVEMENT_LEVEL_ORIGINAL, 1)]
WIDA_RI_Data_LONG_2023[!is.na(ACHIEVEMENT_LEVEL), ACHIEVEMENT_LEVEL:=paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_RI_Data_LONG_2023[,GRADE:=as.character(GRADE)]

WIDA_RI_Data_LONG_2023[, GENDER:=fcase(
                    GENDER=="F", "Female",
                    GENDER=="M", "Male",
                    GENDER=="", as.character(NA))]

WIDA_RI_Data_LONG_2023[,ETHNICITY:=as.character(NA)]
WIDA_RI_Data_LONG_2023[WHITE=="Y", ETHNICITY:="White"]
WIDA_RI_Data_LONG_2023[HISPANIC_LATINO=="Y", ETHNICITY:="Hispanic or Latino"]
WIDA_RI_Data_LONG_2023[INDIAN_ALASKAN_NATIVE=="Y", ETHNICITY:="American Indian or Alaskan Native"]
WIDA_RI_Data_LONG_2023[ASIAN=="Y", ETHNICITY:="Asian"]
WIDA_RI_Data_LONG_2023[BLACK=="Y", ETHNICITY:="African American"]
WIDA_RI_Data_LONG_2023[HAWAIIAN_PI=="Y", ETHNICITY:="Hawaiian or Pacific Islander"]

WIDA_RI_Data_LONG_2023[,c("HISPANIC_LATINO", "INDIAN_ALASKAN_NATIVE", "ASIAN", "BLACK", "HAWAIIAN_PI", "WHITE"):=NULL]

WIDA_RI_Data_LONG_2023[, IEP_STATUS:=fcase(
                    IEP_STATUS=="Y", "IEP Status: Yes",
                    is.na(IEP_STATUS), "IEP Status: No")]

WIDA_RI_Data_LONG_2023[,YEAR:="2023"]
WIDA_RI_Data_LONG_2023[,CONTENT_AREA:="READING"]
WIDA_RI_Data_LONG_2023[,VALID_CASE:="VALID_CASE"]

### Final tidy up
setcolorder(WIDA_RI_Data_LONG_2023, c("VALID_CASE", "CONTENT_AREA", "YEAR", "GRADE", "ID", "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "ACHIEVEMENT_LEVEL_ORIGINAL", "SCHOOL_NUMBER", "SCHOOL_NAME", "DISTRICT_NUMBER", "DISTRICT_NAME", "GENDER", "LENGTH_TIME_ELL_PROGRAM", "IEP_STATUS", "ETHNICITY"))
setkey(WIDA_RI_Data_LONG_2023, VALID_CASE, CONTENT_AREA, YEAR, ID, SCALE_SCORE)
setkey(WIDA_RI_Data_LONG_2023, VALID_CASE, CONTENT_AREA, YEAR, ID)
WIDA_RI_Data_LONG_2023[which(duplicated(WIDA_RI_Data_LONG_2023, by=key(WIDA_RI_Data_LONG_2023)))-1, VALID_CASE := "INVALID_CASE"]

### Save results
save(WIDA_RI_Data_LONG_2023, file="Data/WIDA_RI_Data_LONG_2023.Rdata")
