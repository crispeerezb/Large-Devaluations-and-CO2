######################
# Data for ppp rates #
######################

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
options(digits = 16)


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
ppp_data <- read_excel(file.path(dir_source, "IMF data/ppp rate.xlsx"))


# reshape data
ppp_data <- ppp_data %>% 
  pivot_longer(cols = -c("country"), names_to = "Year", values_to = "ppp_rate")

# replace "no data" with NA
ppp_data$ppp_rate <- ifelse(ppp_data$ppp_rate == "no data", NA, ppp_data$ppp_rate)

# keep only the years 1990-2016
ppp_data <- ppp_data %>% filter(Year >= 1990 & Year <= 2016)

# drop some strange countries manually
ppp_data <- ppp_data %>% filter(country != "Belgium-Luxembourg")
ppp_data <- ppp_data %>% filter(country != "Eastern Germany")
ppp_data <- ppp_data %>% filter(country != "Czechoslovakia")
ppp_data <- ppp_data %>% filter(country != "Yemen, People's Dem. Rep. of")
ppp_data <- ppp_data %>% filter(country != "Yemen Arab Rep.")
ppp_data <- ppp_data %>% filter(country != "Netherlands Antilles")

# Change names manually to later match with our main data set

ppp_data$country <- gsub("Aruba the Netherlands", "Aruba", ppp_data$country)
ppp_data$country <- gsub("Afghanistan, Islamic Rep. of", "Afghanistan", ppp_data$country)
ppp_data$country <- gsub("Andorra, Principality of", "Andorra", ppp_data$country)
ppp_data$country <- gsub("Armenia, Rep. of", "Armenia", ppp_data$country)
ppp_data$country <- gsub("Aruba, Kingdom of the Netherlands", "Aruba", ppp_data$country)
ppp_data$country <- gsub("Azerbaijan, Rep. of", "Azerbaijan", ppp_data$country)
ppp_data$country <- gsub("Bahrain, Kingdom of", "Bahrain", ppp_data$country)
ppp_data$country <- gsub("Bahamas, The", "Bahamas", ppp_data$country)
ppp_data$country <- gsub("Belarus, Rep. of", "Belarus", ppp_data$country)
ppp_data$country <- gsub("Brunei Darussalam", "Brunei", ppp_data$country)
ppp_data$country <- gsub("Central African Rep.", "Central African Republic", ppp_data$country)
ppp_data$country <- gsub("Hong Kong SAR", "Hong Kong", ppp_data$country)
ppp_data$country <- gsub("China, P.R.: Macao", "Macao SAR", ppp_data$country)
ppp_data$country <- gsub("China, P.R.: Mainland", "China", ppp_data$country)
ppp_data$country <- gsub("Croatia, Rep. of", "Croatia", ppp_data$country)
ppp_data$country <- gsub("Czech Rep.", "Czech Republic", ppp_data$country)
ppp_data$country <- gsub("Ethiopia Federal Dem. Rep. of", "Ethiopia", ppp_data$country)
ppp_data$country <- gsub("Dominican Rep.", "Dominican Republic", ppp_data$country)
ppp_data$country <- gsub("Egypt, Arab Rep. of", "Egypt", ppp_data$country)
ppp_data$country <- gsub("Estonia, Rep. of", "Estonia", ppp_data$country)
ppp_data$country <- gsub("Fiji, Rep. of", "Fiji", ppp_data$country)
ppp_data$country <- gsub("Gambia, The", "Gambia", ppp_data$country)
ppp_data$country <- gsub("Iran, Islamic Rep. of", "Iran", ppp_data$country)
ppp_data$country <- gsub("Kazakhstan, Rep. of", "Kazakhstan", ppp_data$country)
ppp_data$country <- gsub("Korea", "South Korea", ppp_data$country)
ppp_data$country <- gsub("Kosovo, Rep. of", "Kosovo", ppp_data$country)
ppp_data$country <- gsub("Lao People's Dem. Rep.", "Laos", ppp_data$country)


ppp_data$country <- gsub("Russian Federation", "Russia", ppp_data$country)
ppp_data$country <- gsub("Poland, Rep. of", "Poland", ppp_data$country)
ppp_data$country <- gsub("San Marino, Rep. of", "San Marino", ppp_data$country)
ppp_data$country <- gsub("São Tomé and Príncipe, Dem. Rep. of", "Sao Tome and Principe", ppp_data$country)
ppp_data$country <- gsub("Serbia, Rep. of", "Serbia", ppp_data$country)
ppp_data$country <- gsub("Syrian Arab Rep.", "Syria", ppp_data$country)
ppp_data$country <- gsub("Taiwan Province of China", "Taiwan", ppp_data$country)
ppp_data$country <- gsub("Tajikistan, Rep. of", "Tajikistan", ppp_data$country)
ppp_data$country <- gsub("Tanzania, United Rep. of", "Tanzania", ppp_data$country)
ppp_data$country <- gsub("Türkiye, Rep of", "Turkey", ppp_data$country)
ppp_data$country <- gsub("Uzbekistan, Rep. of", "Uzbekistan", ppp_data$country)
ppp_data$country <- gsub("Venezuela, Rep. Bolivariana de", "Venezuela", ppp_data$country)
ppp_data$country <- gsub("Yemen, Rep. of", "Yemen", ppp_data$country)

ppp_data$country <- gsub("United Kingdom", "UK", ppp_data$country)
ppp_data$country <- gsub("United States", "USA", ppp_data$country)
ppp_data$country <- gsub("Vietnam", "Viet Nam", ppp_data$country)
ppp_data$country <- gsub("Eritrea State of", "Eritrea", ppp_data$country)


ppp_data$country <- gsub("Netherlands, The", "Netherlands", ppp_data$country)
ppp_data$country <- gsub("Slovak Rep.", "Slovakia", ppp_data$country)
ppp_data$country <- gsub("Slovenia, Rep. of", "Slovenia", ppp_data$country)


ppp_data$country <- gsub(", Rep. of", "", ppp_data$country)
ppp_data$country <- gsub(", Dem. Rep. of", "", ppp_data$country)
ppp_data$country <- gsub(", Islamic Rep. of", "", ppp_data$country)
ppp_data$country <- gsub(", Kingdom of", "", ppp_data$country)
ppp_data$country <- gsub(", The", "", ppp_data$country)
ppp_data$country <- gsub(", Federated States of", "", ppp_data$country)
ppp_data$country <- gsub(", Republic of" , "", ppp_data$country)

ppp_data$country <- gsub("Congo the", "Congo", ppp_data$country)


# add code 3 digits
countries <- read_dta(file.path(dir_output, "data-stata/eora/00-countries.dta"))
ppp_data <- ppp_data %>% left_join(countries, by = "country")

# check which countries did not match
aux <- ppp_data %>% filter(is.na(country_code))
aux <- unique(aux$country)
aux

colnames(ppp_data) <- c("country", "year", "ppp_rate", "country_code")

# proper format for variables, so year as string to merge later
ppp_data$year <- as.numeric(ppp_data$year)
ppp_data$ppp_rate <- as.numeric(ppp_data$ppp_rate)

# save data in dta format
write_dta(ppp_data, file.path(dir_output, "data-stata/imf/02-ppp-rate.dta"))
