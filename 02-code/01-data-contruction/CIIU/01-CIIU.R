######################################
# Create a table with financial crisis
######################################

# packages
library(readxl)
library(dplyr)
library(writexl)
library(tidyr)
library(countrycode)
library(foreign)
library(haven)

# options
rm(list = ls())
options(scipen = 999)
options(encoding = "UTF-8")
options(digits = 9)


# Set working directory
username <- "CP"

if (username == "EZ") {
  dir_base <- "change where you clone the repository"
} else if (username == "CP") {
  dir_base <- "C:/Users/crist/OneDrive/Documentos/GitHub/Large-Devaluations-and-CO2/"
}


dir_source <- file.path(dir_base, "01-raw-data")
wd <- file.path(dir_base, "01-code")
dir_temp <- file.path(dir_base, "03-temp")
dir_output <- file.path(dir_base, "04-output")


# load data set
df_ciiu <- read_excel(file.path(dir_source, "CIIU/Estructura-detallada-CIIU-4AC-2020.xlsx")) 

# just keep the relevant variables
df_ciiu <- df_ciiu %>% select(División, Descripción)

# drop NA in División
df_ciiu <- df_ciiu %>% filter(!is.na(División))

# rename variables
df_ciiu <- df_ciiu %>% rename(ciiu = División, ciiu_desc = Descripción)

# drop last observation
df_ciiu <- df_ciiu %>% filter(!grepl("Publicada", ciiu))

# if the variable ciiu start with "SECCIÓN" then new variable ciiu_section is created with value of ciiu_desc
df_ciiu <- df_ciiu %>% mutate(ciiu_section = ifelse(grepl("SECCIÓN", ciiu), ciiu_desc, NA))

# fill the missing values in ciiu_section forwards
df_ciiu <- df_ciiu %>% fill(ciiu_section)

# drop rows with Sección in ciiu
df_ciiu <- df_ciiu %>% filter(!grepl("SECCIÓN", ciiu))

# remove problematic characters in ciiu_desc and lower case
df_ciiu$ciiu_desc <- tolower(df_ciiu$ciiu_desc)

# all variable as character
df_ciiu <- df_ciiu %>% mutate(across(everything(), as.character))

# replace 01, 02, 03, 04, 05, 06, 07, 08, 09 by 1, 2, 3, 4, 5, 6, 7, 8, 9
df_ciiu$ciiu <- gsub("01", "1", df_ciiu$ciiu)
df_ciiu$ciiu <- gsub("02", "2", df_ciiu$ciiu)
df_ciiu$ciiu <- gsub("03", "3", df_ciiu$ciiu)
df_ciiu$ciiu <- gsub("04", "4", df_ciiu$ciiu)
df_ciiu$ciiu <- gsub("05", "5", df_ciiu$ciiu)
df_ciiu$ciiu <- gsub("06", "6", df_ciiu$ciiu)
df_ciiu$ciiu <- gsub("07", "7", df_ciiu$ciiu)
df_ciiu$ciiu <- gsub("08", "8", df_ciiu$ciiu)
df_ciiu$ciiu <- gsub("09", "9", df_ciiu$ciiu)


# rename ciiu variable by ciiu_2
df_ciiu <- df_ciiu %>% rename(ciiu_2 = ciiu)

# save data set as dta
write_dta(df_ciiu, file.path(dir_output, "/data-stata/eam/00-eam_ciiu.dta"))
