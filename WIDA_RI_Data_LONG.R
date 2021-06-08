####################################################################################
###                                                                              ###
###    Create LONG WIDA Rhode Island data from 2018-2019 and 2019-2020 base file ###
###                                                                              ###
####################################################################################

### Utility functions

strhead <- function (s, n) {
    if (n < 0)
        substr(s, 1, nchar(s) + n)
    else substr(s, 1, n)
}

### Load packages
require(data.table)



### Load data
tmp_2017_2018 <- fread("Data/Base_Files/RI_Summative_StudRR_File_2018-06-07.csv", na.strings=c("NULL", "NA"))
tmp_2018_2019 <- fread("Data/Base_Files/2019_ACCESS.txt", na.strings=c("NULL", "NA"))
tmp_2019_2020 <- fread("Data/Base_Files/RI_Summative_StudRR_File_2020-06-22.csv", na.strings=c("NULL", "NA"))

### Subset data
variables.to.keep <- c("District Name", "District Number", "School Number", "School Name", "State Student ID", "Composite (Overall) Scale Score", "Composite (Overall) Proficiency Level", "Grade")
tmp_2017_2018 <- tmp_2017_2018[,variables.to.keep, with=FALSE][,YEAR:="2018"]
tmp_2018_2019 <- tmp_2018_2019[,variables.to.keep, with=FALSE][,YEAR:="2019"]
tmp_2019_2020 <- tmp_2019_2020[,variables.to.keep, with=FALSE][,YEAR:="2020"]

### Stack data
WIDA_RI_Data_LONG <- rbindlist(list(tmp_2017_2018, tmp_2018_2019, tmp_2019_2020))

### Rename variables
old.names <- c("District Name", "District Number", "School Number", "School Name", "State Student ID", "Composite (Overall) Scale Score", "Composite (Overall) Proficiency Level", "Grade")
new.names <- c("DISTRICT_NAME", "DISTRICT_NUMBER", "SCHOOL_NUMBER", "SCHOOL_NAME", "ID", "SCALE_SCORE", "ACHIEVEMENT_LEVEL_ORIGINAL", "GRADE")
setnames(WIDA_RI_Data_LONG, old.names, new.names)

### Tidy up variables
WIDA_RI_Data_LONG[,ID:=as.character(ID)]
WIDA_RI_Data_LONG[,SCALE_SCORE:=as.numeric(SCALE_SCORE)]
WIDA_RI_Data_LONG[,ACHIEVEMENT_LEVEL_ORIGINAL:=as.character(ACHIEVEMENT_LEVEL_ORIGINAL)]
WIDA_RI_Data_LONG[,ACHIEVEMENT_LEVEL:=strhead(ACHIEVEMENT_LEVEL_ORIGINAL, 1)]
WIDA_RI_Data_LONG[!is.na(ACHIEVEMENT_LEVEL), ACHIEVEMENT_LEVEL:=paste("WIDA Level", ACHIEVEMENT_LEVEL)]
WIDA_RI_Data_LONG[,GRADE:=as.character(as.numeric(GRADE))]
WIDA_RI_Data_LONG[,CONTENT_AREA:="READING"]
WIDA_RI_Data_LONG[,VALID_CASE:="VALID_CASE"]

### Final tidy up
setcolorder(WIDA_RI_Data_LONG, c("VALID_CASE", "CONTENT_AREA", "YEAR", "GRADE", "ID", "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "ACHIEVEMENT_LEVEL_ORIGINAL", "SCHOOL_NUMBER", "SCHOOL_NAME", "DISTRICT_NUMBER", "DISTRICT_NAME"))
setkey(WIDA_RI_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID, SCALE_SCORE)
setkey(WIDA_RI_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID)
WIDA_RI_Data_LONG[which(duplicated(WIDA_RI_Data_LONG, by=key(WIDA_RI_Data_LONG)))-1, VALID_CASE := "INVALID_CASE"]

### Save results
save(WIDA_RI_Data_LONG, file="Data/WIDA_RI_Data_LONG.Rdata")
