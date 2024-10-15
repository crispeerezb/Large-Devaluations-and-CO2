#########################
# Data for GDP deflator #
#########################

# packages
library(readxl)
library(dplyr)
library(writexl)
library(tidyr)
library(ggplot2)
library(haven)

# options
rm(list = ls())
options(encoding = "UTF-8")
options(digits = 10)


# Set working directory
username <- "CP"

if (username == "EZ") {
  dir_base <- "change where you clone the repository"
} else if (username == "CP") {
  dir_base <- "C:/Users/crist/OneDrive/Documentos/GitHub/Large-Devaluations-and-CO2"
}


dir_source <- file.path(dir_base, "01-raw-data")
wd <- file.path(dir_base, "02-code")
dir_temp <- file.path(dir_base, "03-temp")
dir_output <- file.path(dir_base, "04-output")

# load data
gdp_deflator <- read_excel(file.path(dir_source, "/World Bank/GDP Deflator.xlsx"), sheet = "Data")

# drop columns Indicator Name and Indicator Code
gdp_deflator <- gdp_deflator %>% select(-c("Indicator Name", "Indicator Code"))

# reshape data to long format
gdp_deflator <- gdp_deflator %>% 
  pivot_longer(cols = -c("Country Name", "Country Code"), names_to = "Year", values_to = "GDP_Deflator")

# keep years from 1990 to 2019
gdp_deflator <- gdp_deflator %>% filter(Year >= 1990 & Year <= 2009)

# change column names
colnames(gdp_deflator) <- c("country", "country_code", "year", "gdp_deflator")

# just to match with my stata format
gdp_deflator$year <- as.numeric(gdp_deflator$year)
gdp_deflator$gdp_deflator <- as.numeric(gdp_deflator$gdp_deflator)
gdp_deflator$country_code <- as.character(gdp_deflator$country_code)

# drop column country because it is in spanish
gdp_deflator <- gdp_deflator %>% select(-c("country"))

# drop if gdp_deflator is NA
gdp_deflator <- gdp_deflator %>% filter(!is.na(gdp_deflator))

# check if we have a balance panel, so we add a new column to check if we have all the years for each country
gdp_deflator <- gdp_deflator %>% group_by(country_code) %>% mutate(n = n()) %>% ungroup()

# check those countries with n<20
aux <- gdp_deflator %>% filter(n < 20) %>% select(country_code, n) %>% distinct()
countries_to_drop <- aux$country_code

# drop countries with n<20
gdp_deflator <- gdp_deflator %>% filter(!country_code %in% countries_to_drop)


# drop column n
gdp_deflator <- gdp_deflator %>% select(-c("n"))


# save data as dta
write_dta(gdp_deflator, file.path(dir_output, "/data-stata/world bank/02-gdp_deflator.dta"))
