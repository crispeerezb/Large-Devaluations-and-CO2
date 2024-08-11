###################################
# Data for Emissions and GDP PPPs #
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
gdp_ppp <- read_excel(file.path(dir_source, "/World Bank/GDP PPPs.xlsx"), sheet = "Data", range = "A4:BP270")
co2_emissions <- read_excel(file.path(dir_source, "/World Bank/CO2 Emissions.xlsx"), sheet = "Data", range = "A4:BM270")
countries <- read_dta(file.path(dir_output, "data-stata/eora/00-countries.dta"))

# improve format: replace spaces in column names with "_"
names(gdp_ppp) <- gsub(" ", "_", names(gdp_ppp))
names(co2_emissions) <- gsub(" ", "_", names(co2_emissions))

# improve format: keep only relevant columns
gdp_ppp <- gdp_ppp %>% select(-Indicator_Code)
co2_emissions <- co2_emissions %>% select(-Indicator_Code)

# reshape data
gdp_ppp <- gdp_ppp %>% 
  pivot_longer(cols = -c(Country_Name, Country_Code, Indicator_Name), names_to = "Year", values_to = "GDP_PPP") %>% 
  mutate(GDP_PPP = as.numeric(GDP_PPP)) %>% select(-Indicator_Name)

co2_emissions <- co2_emissions %>%
  pivot_longer(cols = -c(Country_Name, Country_Code, Indicator_Name), names_to = "Year", values_to = "CO2_Emissions") %>% 
  mutate(CO2_Emissions = as.numeric(CO2_Emissions)*1000000) %>% select(-Indicator_Name)

# just keep years from 1990-2019 (to avoid pandemic effects)
gdp_ppp <- gdp_ppp %>% filter(Year >= 1990 & Year <= 2019)
co2_emissions <- co2_emissions %>% filter(Year >= 1990 & Year <= 2019)

# merge data
data <- inner_join(gdp_ppp, co2_emissions, by = c("Country_Name", "Country_Code", "Year"))

# add co2 rates
data$co2_rates <- data$CO2_Emissions/data$GDP_PPP

# then keep countries that are in the EORA dataset (by country code)
data <- data %>% filter(Country_Code %in% countries$country_code)

# export as dta data
write_dta(data, file.path(dir_output, "/data-stata/world bank/01-emissions-rates.dta"))




