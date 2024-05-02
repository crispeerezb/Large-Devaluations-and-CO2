# load libraries
library(dplyr)
library(readr)
library(readxl)
library(haven)

# clean workspace
rm(list = ls())

# set path
dir_base <- "C:/Users/crist/OneDrive/Documentos/GitHub/Large-Devaluations-and-CO2"
dir_raw <- file.path(dir_base, "01-raw-data")
dir_output <- file.path(dir_base, "04-output")

# read data
inflation <- read_excel(file.path(dir_raw, "macroeconomic indicators/USA/PCECTPI.xls"), range = "A11:B152")

# declare observation_date as date
inflation <- inflation %>% 
  mutate(observation_date = as.Date(observation_date, format = "%Y-%m-%d"))

# create a new variable called inflation_rate
inflation <- inflation %>% 
  mutate(inflation_rate = (PCECTPI/lag(PCECTPI, 4) - 1))

# collapse the data to annual frequency
inflation_annual <- inflation %>%
  mutate(year = as.numeric(format(observation_date, "%Y"))) %>%
  group_by(year) %>% 
  summarise(inflation_rate = mean(inflation_rate, na.rm = TRUE))

# save the data in dta format
write_dta(inflation_annual, file.path(dir_output, "data-stata/macro-indicators/02-inflation_annual_usa.dta"))
