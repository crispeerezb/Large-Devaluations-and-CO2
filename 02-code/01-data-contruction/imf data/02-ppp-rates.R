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
ppp_data <- ppp_data %>% filter(Year >= 1990 & Year <= 2009)

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

# other changes
ppp_data$country <- gsub("Ethiopia Federal Dem. Rep. of", "Ethiopia", ppp_data$country)
ppp_data$country <- gsub("United Arab Emirates", "Saudi Arabia", ppp_data$country)
ppp_data$country <- gsub("North Macedonia", "TFYR Macedonia", ppp_data$country)
ppp_data$country <- gsub("Antigua and Barbuda", "Antigua", ppp_data$country)
ppp_data$country <- gsub("Cabo Verde", "Cape Verde", ppp_data$country)
ppp_data$country <- gsub("Equatorial Guinea", "Guinea", ppp_data$country)
ppp_data$country <- gsub("Eritrea State of", "Eritrea", ppp_data$country)
ppp_data$country <- gsub("Kyrgyz Rep.", "Kyrgyzstan", ppp_data$country)
ppp_data$country <- gsub("Czech Republicblic", "Czech Republic", ppp_data$country)
ppp_data$country <- gsub("Central African Republicblic", "Central African Republic", ppp_data$country)
ppp_data$country <- gsub("Dominican Republicblic", "Dominican Republic", ppp_data$country)
ppp_data$country <- gsub("China, People's Republic of", "China", ppp_data$country)




# add code 3 digits
countries <- read_dta(file.path(dir_output, "data-stata/eora/00-countries.dta"))


# we drop some countries that are not relevant in this analysis

# Anguilla
ppp_data <- ppp_data %>% filter(country != "Anguilla")

# Comoros
ppp_data <- ppp_data %>% filter(country != "Comoros")

# Côte d'Ivoire
ppp_data <- ppp_data %>% filter(country != "Côte d'Ivoire")

# Curaçao and Sint Maarten
ppp_data <- ppp_data %>% filter(country != "Curaçao and Sint Maarten")

# Curaçao the Netherlands
ppp_data <- ppp_data %>% filter(country != "Curaçao the Netherlands")

# Dominica
ppp_data <- ppp_data %>% filter(country != "Dominica")

# Euro Area
ppp_data <- ppp_data %>% filter(country != "Euro Area")

# Eswatini
ppp_data <- ppp_data %>% filter(country != "Eswatini")

# USSR
ppp_data <- ppp_data %>% filter(country != "USSR")

# Yugoslavia
ppp_data <- ppp_data %>% filter(country != "Yugoslavia")

# Comoros
ppp_data <- ppp_data %>% filter(country != "Comoros")

# Faroe Islands
ppp_data <- ppp_data %>% filter(country != "Faroe Islands")

# Gibraltar
ppp_data <- ppp_data %>% filter(country != "Gibraltar")

# Grenada
ppp_data <- ppp_data %>% filter(country != "Grenada")

# Guadeloupe
ppp_data <- ppp_data %>% filter(country != "Guadeloupe")

# Guinea-Bissau
ppp_data <- ppp_data %>% filter(country != "Guinea-Bissau")

# Isle of Man
ppp_data <- ppp_data %>% filter(country != "Isle of Man")

# Jersey
ppp_data <- ppp_data %>% filter(country != "Jersey")

# Kiribati
ppp_data <- ppp_data %>% filter(country != "Kiribati")

# Kosovo
ppp_data <- ppp_data %>% filter(country != "Kosovo")

# Martinique
ppp_data <- ppp_data %>% filter(country != "Martinique")

# Micronesia
ppp_data <- ppp_data %>% filter(country != "Micronesia")

# Montserrat
ppp_data <- ppp_data %>% filter(country != "Montserrat")

# Nauru
ppp_data <- ppp_data %>% filter(country != "Nauru")

# Palau
ppp_data <- ppp_data %>% filter(country != "Palau")

# Reunion
ppp_data <- ppp_data %>% filter(country != "Reunion")

# Saint Pierre and Miquelon
ppp_data <- ppp_data %>% filter(country != "Saint Pierre and Miquelon")

# Sint Maarten the Netherlands
ppp_data <- ppp_data %>% filter(country != "Sint Maarten the Netherlands")

# Solomon Islands
ppp_data <- ppp_data %>% filter(country != "Solomon Islands")

# St. Kitts and Nevis
ppp_data <- ppp_data %>% filter(country != "St. Kitts and Nevis")

# St. Lucia
ppp_data <- ppp_data %>% filter(country != "St. Lucia")

# St. Vincent and the Grenadines
ppp_data <- ppp_data %>% filter(country != "St. Vincent and the Grenadines")

# Timor-Leste
ppp_data <- ppp_data %>% filter(country != "Timor-Leste")

# Tonga
ppp_data <- ppp_data %>% filter(country != "Tonga")

# Comoros, Union of the"
ppp_data <- ppp_data %>% filter(country != "Comoros, Union of the")

# Guernsey
ppp_data <- ppp_data %>% filter(country != "Guernsey")

# Guiana, French
ppp_data <- ppp_data %>% filter(country != "Guiana, French")

# left join
ppp_data <- ppp_data %>% left_join(countries, by = "country")

# check which countries did not match
aux <- ppp_data %>% filter(is.na(country_code))
aux <- unique(aux$country)
aux

colnames(ppp_data) <- c("country", "year", "ppp_rate", "country_code")

# proper format for variables, so year as string to merge later
ppp_data$year <- as.numeric(ppp_data$year)
ppp_data$ppp_rate <- as.numeric(ppp_data$ppp_rate)

# drop those observation that are in aux
ppp_data <- ppp_data %>% filter(!country %in% aux)

# save data in dta format
write_dta(ppp_data, file.path(dir_output, "data-stata/imf/02-ppp-rate.dta"))
