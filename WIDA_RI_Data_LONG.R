#################################################################################
###
### Data preparation script for WIDA RI data, 2011-2016
###
#################################################################################

### Load Packages

require(data.table)


### Utility function

strtail <- function (s, n = 1) {
    if (n < 0)
        substring(s, 1 - n)
    else substring(s, nchar(s) - n + 1)
}

strhead <- function (s, n) {
    if (n < 0)
        substr(s, 1, nchar(s) + n)
    else substr(s, 1, n)
}

### Load Data

WIDA_RI_Data_LONG <- fread("Data/Base_Files/RI_ACCESS_2011_2016.csv", colClasses=rep("character", 5))

### Clean Up Data

setnames(WIDA_RI_Data_LONG, c("ID", "GRADE", "SCALE_SCORE", "PROF_LEVEL", "YEAR"))
WIDA_RI_Data_LONG[, GRADE:=as.character(as.numeric(GRADE))]
WIDA_RI_Data_LONG[,VALID_CASE := "VALID_CASE"]
WIDA_RI_Data_LONG[,CONTENT_AREA := "READING"]
WIDA_RI_Data_LONG[,YEAR := strtail(YEAR, 4)]
WIDA_RI_Data_LONG[,SCALE_SCORE := as.numeric(SCALE_SCORE)]
WIDA_RI_Data_LONG[,ACHIEVEMENT_LEVEL := as.character(WIDA_RI_Data_LONG$PROF_LEVEL)]
WIDA_RI_Data_LONG[,ACHIEVEMENT_LEVEL := strhead(ACHIEVEMENT_LEVEL, 1)]
WIDA_RI_Data_LONG[!is.na(ACHIEVEMENT_LEVEL), ACHIEVEMENT_LEVEL := paste("WIDA Level", ACHIEVEMENT_LEVEL)]


### Invalidate Cases with Scale Score out of Range (PROF_LEVEL in c("", " NA", "A1", "A2", "A3", "P1", "P2"))

WIDA_RI_Data_LONG[nchar(ID)!=10, VALID_CASE := "INVALID_CASE"]
WIDA_RI_Data_LONG[is.na(SCALE_SCORE), VALID_CASE := "INVALID_CASE"]
WIDA_RI_Data_LONG[ACHIEVEMENT_LEVEL=="", VALID_CASE := "INVALID_CASE"]


### Check for duplicates

setkey(WIDA_RI_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID, GRADE, SCALE_SCORE)
setkey(WIDA_RI_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID)
WIDA_RI_Data_LONG[which(duplicated(WIDA_RI_Data_LONG, by=key(WIDA_RI_Data_LONG)))-1, VALID_CASE := "INVALID_CASE"]
setkey(WIDA_RI_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID)


### Reorder

setcolorder(WIDA_RI_Data_LONG, c("VALID_CASE", "ID", "CONTENT_AREA", "YEAR", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "PROF_LEVEL"))


### Save data

save(WIDA_RI_Data_LONG, file="Data/WIDA_RI_Data_LONG.Rdata")
