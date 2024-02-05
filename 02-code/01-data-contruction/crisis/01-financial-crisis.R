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

# load data about financial crisis
df_financial_crisis <- read_xlsx(file.path(dir_source, "IMF Crisis Data/SYSTEMIC BANKING CRISES DATABASE_2018.xlsx"),
                                 sheet = "Crisis Years")

#################################################
# 1) Create a table with type of financial crisis
#################################################

# Drop first row
df_financial_crisis <- df_financial_crisis[-1, ]

# create a dataframe with the type of financial crisis
df_sistemic_banking_crisis <- df_financial_crisis %>%
  select(Country, `Systemic Banking Crisis (starting date)`)

df_currency_crisis <- df_financial_crisis %>%
  select(Country, `Currency Crisis`)

df_sovereign_debt_crisis <- df_financial_crisis %>%
  select(Country, `Sovereign Debt Crisis (year)`) 

df_sovereign_debt_restructuring  <- df_financial_crisis %>%
  select(Country, `Sovereign Debt Restructuring (year)`)

# change colnames to manipulate the data easier
colnames(df_sistemic_banking_crisis) <- c("Country", "sis_banking_crisis")
colnames(df_currency_crisis) <- c("Country", "currency_crisis")
colnames(df_sovereign_debt_crisis) <- c("Country", "sovereign_debt_crisis")
colnames(df_sovereign_debt_restructuring) <- c("Country", "sovereign_debt_restructuring")

# repeat values for each country
df_sistemic_banking_crisis <- df_sistemic_banking_crisis %>%
  separate_rows(sis_banking_crisis, sep = ", ") %>%
  na.omit()

df_currency_crisis <- df_currency_crisis %>%
  separate_rows(currency_crisis, sep = ", ") %>%
  na.omit()

df_sovereign_debt_crisis <- df_sovereign_debt_crisis %>%
  separate_rows(sovereign_debt_crisis, sep = ", ") %>%
  na.omit()

df_sovereign_debt_restructuring <- df_sovereign_debt_restructuring %>%
  separate_rows(sovereign_debt_restructuring, sep = ", ") %>%
  na.omit()

# create a column with ones for merge later
df_sistemic_banking_crisis$sis_banking_crisis_event <- 1
df_currency_crisis$currency_crisis_event <- 1
df_sovereign_debt_crisis$sovereign_debt_crisis_event <- 1
df_sovereign_debt_restructuring$sovereign_debt_restructuring_event <- 1


# create a panel with the type of financial crisis from 1990 to 2016
all_countries <- unique(df_financial_crisis$Country)
all_years <- 1990:2016
panel_data <- expand.grid(Country = all_countries, Year = all_years)
panel_data <- arrange(panel_data, Country, Year)

# change the type of the columns to character
panel_data$Country <- as.character(panel_data$Country)
panel_data$Year <- as.character(panel_data$Year)

# merge the data
panel_data <- left_join(panel_data, df_sistemic_banking_crisis, by = c("Country" = "Country", "Year" = "sis_banking_crisis")) %>%
  left_join(df_currency_crisis, by = c("Country" = "Country", "Year" = "currency_crisis")) %>%
  left_join(df_sovereign_debt_crisis, by = c("Country" = "Country", "Year" = "sovereign_debt_crisis")) %>%
  left_join(df_sovereign_debt_restructuring, by = c("Country" = "Country", "Year" = "sovereign_debt_restructuring"))

# add country code
panel_data$Country[panel_data$Country == "Yugoslavia, SFR"] <- "Yugoslavia"
panel_data$country_code <- countrycode(panel_data$Country, origin = "country.name", destination = "iso3c")
  
# drop if country code is NA
panel_data <- panel_data %>%
  filter(!is.na(country_code))

# save the data in stata format to use in the main analysis
write.dta(panel_data, file.path(dir_output, "data-stata/financial-crisis/financial-crisis_country-year.dta"))

