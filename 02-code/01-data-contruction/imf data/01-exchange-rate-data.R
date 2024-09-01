###################################
# Data for exchange rate deflator #
###################################

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
exchange_rate <- read_excel(file.path(dir_source, "IMF data/fx data.xlsx"), range = "A2:CH223")

# drop indicator column
exchange_rate <- exchange_rate %>% select(-c(Indicator))

# reshape data
exchange_rate <- exchange_rate %>% 
  pivot_longer(cols = -c("Country"), names_to = "Year", values_to = "exchange_rate")

# keep only the years 1990-2019
exchange_rate <- exchange_rate %>% filter(Year >= 1990 & Year <= 2019)

# drop some strange countries manually
exchange_rate <- exchange_rate %>% filter(Country != "Belgium-Luxembourg")
exchange_rate <- exchange_rate %>% filter(Country != "Eastern Germany")
exchange_rate <- exchange_rate %>% filter(Country != "Czechoslovakia")
exchange_rate <- exchange_rate %>% filter(Country != "Yemen, People's Dem. Rep. of")
exchange_rate <- exchange_rate %>% filter(Country != "Yemen Arab Rep.")
exchange_rate <- exchange_rate %>% filter(Country != "Netherlands Antilles")

# Change names manually to later match with our main data set

exchange_rate$Country <- gsub("Aruba the Netherlands", "Aruba", exchange_rate$Country)
exchange_rate$Country <- gsub("Afghanistan, Islamic Rep. of", "Afghanistan", exchange_rate$Country)
exchange_rate$Country <- gsub("Andorra, Principality of", "Andorra", exchange_rate$Country)
exchange_rate$Country <- gsub("Armenia, Rep. of", "Armenia", exchange_rate$Country)
exchange_rate$Country <- gsub("Aruba, Kingdom of the Netherlands", "Aruba", exchange_rate$Country)
exchange_rate$Country <- gsub("Azerbaijan, Rep. of", "Azerbaijan", exchange_rate$Country)
exchange_rate$Country <- gsub("Bahrain, Kingdom of", "Bahrain", exchange_rate$Country)
exchange_rate$Country <- gsub("Bahamas, The", "Bahamas", exchange_rate$Country)
exchange_rate$Country <- gsub("Belarus, Rep. of", "Belarus", exchange_rate$Country)
exchange_rate$Country <- gsub("Brunei Darussalam", "Brunei", exchange_rate$Country)
exchange_rate$Country <- gsub("Central African Rep.", "Central African Republic", exchange_rate$Country)
exchange_rate$Country <- gsub("China, P.R.: Hong Kong", "Hong Kong", exchange_rate$Country)
exchange_rate$Country <- gsub("China, P.R.: Macao", "Macao SAR", exchange_rate$Country)
exchange_rate$Country <- gsub("China, P.R.: Mainland", "China", exchange_rate$Country)
exchange_rate$Country <- gsub("Croatia, Rep. of", "Croatia", exchange_rate$Country)
exchange_rate$Country <- gsub("Czech Rep.", "Czech Republic", exchange_rate$Country)
exchange_rate$Country <- gsub("Ethiopia Federal Dem. Rep. of", "Ethiopia", exchange_rate$Country)
exchange_rate$Country <- gsub("Dominican Rep.", "Dominican Republic", exchange_rate$Country)
exchange_rate$Country <- gsub("Egypt, Arab Rep. of", "Egypt", exchange_rate$Country)
exchange_rate$Country <- gsub("Estonia, Rep. of", "Estonia", exchange_rate$Country)
exchange_rate$Country <- gsub("Fiji, Rep. of", "Fiji", exchange_rate$Country)
exchange_rate$Country <- gsub("Gambia, The", "Gambia", exchange_rate$Country)
exchange_rate$Country <- gsub("Iran, Islamic Rep. of", "Iran", exchange_rate$Country)
exchange_rate$Country <- gsub("Kazakhstan, Rep. of", "Kazakhstan", exchange_rate$Country)
exchange_rate$Country <- gsub("Korea, Rep. of", "South Korea", exchange_rate$Country)
exchange_rate$Country <- gsub("Kosovo, Rep. of", "Kosovo", exchange_rate$Country)
exchange_rate$Country <- gsub("Lao People's Dem. Rep.", "Laos", exchange_rate$Country)


exchange_rate$Country <- gsub("Russian Federation", "Russia", exchange_rate$Country)
exchange_rate$Country <- gsub("Poland, Rep. of", "Poland", exchange_rate$Country)
exchange_rate$Country <- gsub("San Marino, Rep. of", "San Marino", exchange_rate$Country)
exchange_rate$Country <- gsub("São Tomé and Príncipe, Dem. Rep. of", "Sao Tome and Principe", exchange_rate$Country)
exchange_rate$Country <- gsub("Serbia, Rep. of", "Serbia", exchange_rate$Country)
exchange_rate$Country <- gsub("Syrian Arab Rep.", "Syria", exchange_rate$Country)
exchange_rate$Country <- gsub("Taiwan Province of China", "Taiwan", exchange_rate$Country)
exchange_rate$Country <- gsub("Tajikistan, Rep. of", "Tajikistan", exchange_rate$Country)
exchange_rate$Country <- gsub("Tanzania, United Rep. of", "Tanzania", exchange_rate$Country)
exchange_rate$Country <- gsub("Türkiye, Rep of", "Turkey", exchange_rate$Country)
exchange_rate$Country <- gsub("Uzbekistan, Rep. of", "Uzbekistan", exchange_rate$Country)
exchange_rate$Country <- gsub("Venezuela, Rep. Bolivariana de", "Venezuela", exchange_rate$Country)
exchange_rate$Country <- gsub("Yemen, Rep. of", "Yemen", exchange_rate$Country)

exchange_rate$Country <- gsub("United Kingdom", "UK", exchange_rate$Country)
exchange_rate$Country <- gsub("United States", "USA", exchange_rate$Country)
exchange_rate$Country <- gsub("Vietnam", "Viet Nam", exchange_rate$Country)
exchange_rate$Country <- gsub("Eritrea State of", "Eritrea", exchange_rate$Country)


exchange_rate$Country <- gsub("Netherlands, The", "Netherlands", exchange_rate$Country)
exchange_rate$Country <- gsub("Slovak Rep.", "Slovakia", exchange_rate$Country)
exchange_rate$Country <- gsub("Slovenia, Rep. of", "Slovenia", exchange_rate$Country)


exchange_rate$Country <- gsub(", Rep. of", "", exchange_rate$Country)
exchange_rate$Country <- gsub(", Dem. Rep. of", "", exchange_rate$Country)
exchange_rate$Country <- gsub(", Islamic Rep. of", "", exchange_rate$Country)
exchange_rate$Country <- gsub(", Kingdom of", "", exchange_rate$Country)
exchange_rate$Country <- gsub(", The", "", exchange_rate$Country)
exchange_rate$Country <- gsub(", Federated States of", "", exchange_rate$Country)
exchange_rate$Country <- gsub(", Republic of" , "", exchange_rate$Country)

exchange_rate$Country <- gsub("Congo the", "Congo", exchange_rate$Country)

unique(exchange_rate$Country)

# we note that some european countries have no data from certain time. We need to add data to those countries and this come from "Euro Area".
# However, countries enter to the Euro Area at different times, so we change this manually.

# 1) first we identify the countries that are in the Euro Area and when they entered
euro_countries <- tibble(Country = c("Austria", "Belgium", "Cyprus", "Estonia", "Finland", "France",
                                     "Germany", "Greece", "Ireland", "Italy", "Latvia", "Lithuania",
                                     "Luxembourg", "Malta", "Netherlands", "Portugal", "Slovakia",
                                     "Slovenia", "Spain"),
                         Euro_Adoption_Year = c(1999, 1999, 2008, 2011, 1999, 1999, 1999, 2001, 1999, 1999,
                                                2014, 2015, 1999, 2008, 1999, 1999, 2009, 2007, 1999))


# 2) we add the information to when the countries entered the Euro Area
exchange_rate <- exchange_rate %>%
  left_join(euro_countries, by = "Country")

# 3) we save exchange_rate for "Euro Area"
euro_area_data <- exchange_rate %>% 
  filter(Country == "Euro Area") %>% 
  select(-c(Euro_Adoption_Year)) %>% na.omit()

# 4) we add a new column in exchange_rate to identify the countries that are in the Euro Area
exchange_rate <- exchange_rate %>% 
  mutate(Euro_Area = ifelse(Country %in% euro_countries$Country, "Euro Area", NA))

# 5) left join the data for the Euro Area
exchange_rate <- exchange_rate %>% 
  left_join(euro_area_data, by = c("Euro_Area" = "Country", "Year"))

# 6) create the final exchange_rate variable
exchange_rate$exchange_rate <- ifelse(exchange_rate$Euro_Area == "Euro Area" & exchange_rate$Year >= exchange_rate$Euro_Adoption_Year & is.na(exchange_rate$exchange_rate.x),
                                      exchange_rate$exchange_rate.y, exchange_rate$exchange_rate.x)

exchange_rate <- exchange_rate %>% select(-c("exchange_rate.x", "exchange_rate.y", "Euro_Area", "Euro_Adoption_Year"))

exchange_rate$exchange_rate <- as.numeric(exchange_rate$exchange_rate)
exchange_rate$Year <- as.numeric(exchange_rate$Year)

colnames(exchange_rate) <- c("country", "year", "exchange_rate")

# other changes
exchange_rate$country <- gsub("Ethiopia Federal Dem. Rep. of", "Ethiopia", exchange_rate$country)
exchange_rate$country <- gsub("United Arab Emirates", "Saudi Arabia", exchange_rate$country)
exchange_rate$country <- gsub("North Macedonia", "TFYR Macedonia", exchange_rate$country)
exchange_rate$country <- gsub("Antigua and Barbuda", "Antigua", exchange_rate$country)
exchange_rate$country <- gsub("Cabo Verde", "Cape Verde", exchange_rate$country)
exchange_rate$country <- gsub("Equatorial Guinea", "Guinea", exchange_rate$country)
exchange_rate$country <- gsub("Eritrea State of", "Eritrea", exchange_rate$country)
exchange_rate$country <- gsub("Kyrgyz Rep.", "Kyrgyzstan", exchange_rate$country)


# add code 3 digits
countries <- read_dta(file.path(dir_output, "data-stata/eora/00-countries.dta"))

# we drop some countries that are not relevant in this analysis

# Anguilla
exchange_rate <- exchange_rate %>% filter(country != "Anguilla")

# Comoros
exchange_rate <- exchange_rate %>% filter(country != "Comoros")

# Côte d'Ivoire
exchange_rate <- exchange_rate %>% filter(country != "Côte d'Ivoire")

# Curaçao and Sint Maarten
exchange_rate <- exchange_rate %>% filter(country != "Curaçao and Sint Maarten")

# Curaçao the Netherlands
exchange_rate <- exchange_rate %>% filter(country != "Curaçao the Netherlands")

# Dominica
exchange_rate <- exchange_rate %>% filter(country != "Dominica")

# Euro Area
exchange_rate <- exchange_rate %>% filter(country != "Euro Area")

# Eswatini
exchange_rate <- exchange_rate %>% filter(country != "Eswatini")

# USSR
exchange_rate <- exchange_rate %>% filter(country != "USSR")

# Yugoslavia
exchange_rate <- exchange_rate %>% filter(country != "Yugoslavia")

# Comoros
exchange_rate <- exchange_rate %>% filter(country != "Comoros")

# Faroe Islands
exchange_rate <- exchange_rate %>% filter(country != "Faroe Islands")

# Gibraltar
exchange_rate <- exchange_rate %>% filter(country != "Gibraltar")

# Grenada
exchange_rate <- exchange_rate %>% filter(country != "Grenada")

# Guadeloupe
exchange_rate <- exchange_rate %>% filter(country != "Guadeloupe")

# Guinea-Bissau
exchange_rate <- exchange_rate %>% filter(country != "Guinea-Bissau")

# Isle of Man
exchange_rate <- exchange_rate %>% filter(country != "Isle of Man")

# Jersey
exchange_rate <- exchange_rate %>% filter(country != "Jersey")

# Kiribati
exchange_rate <- exchange_rate %>% filter(country != "Kiribati")

# Kosovo
exchange_rate <- exchange_rate %>% filter(country != "Kosovo")

# Martinique
exchange_rate <- exchange_rate %>% filter(country != "Martinique")

# Micronesia
exchange_rate <- exchange_rate %>% filter(country != "Micronesia")

# Montserrat
exchange_rate <- exchange_rate %>% filter(country != "Montserrat")

# Nauru
exchange_rate <- exchange_rate %>% filter(country != "Nauru")

# Palau
exchange_rate <- exchange_rate %>% filter(country != "Palau")

# Reunion
exchange_rate <- exchange_rate %>% filter(country != "Reunion")

# Saint Pierre and Miquelon
exchange_rate <- exchange_rate %>% filter(country != "Saint Pierre and Miquelon")

# Sint Maarten the Netherlands
exchange_rate <- exchange_rate %>% filter(country != "Sint Maarten the Netherlands")

# Solomon Islands
exchange_rate <- exchange_rate %>% filter(country != "Solomon Islands")

# St. Kitts and Nevis
exchange_rate <- exchange_rate %>% filter(country != "St. Kitts and Nevis")

# St. Lucia
exchange_rate <- exchange_rate %>% filter(country != "St. Lucia")

# St. Vincent and the Grenadines
exchange_rate <- exchange_rate %>% filter(country != "St. Vincent and the Grenadines")

# Timor-Leste
exchange_rate <- exchange_rate %>% filter(country != "Timor-Leste")

# Tonga
exchange_rate <- exchange_rate %>% filter(country != "Tonga")

# Comoros, Union of the"
exchange_rate <- exchange_rate %>% filter(country != "Comoros, Union of the")

# Guernsey
exchange_rate <- exchange_rate %>% filter(country != "Guernsey")

# Guiana, French
exchange_rate <- exchange_rate %>% filter(country != "Guiana, French")

# left join
exchange_rate <- exchange_rate %>% left_join(countries, by = "country")

# check which countries did not match
aux <- exchange_rate %>% filter(is.na(country_code))
aux <- unique(aux$country)
aux

# proper format for variables, so year as string to merge later
# exchange_rate$year <- as.numeric(exchange_rate$year)

# save data in dta format
write_dta(exchange_rate, file.path(dir_output, "data-stata/imf/01-exchange-rate.dta"))
