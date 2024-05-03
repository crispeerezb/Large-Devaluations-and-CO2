# load libraries
library(dplyr)
library(readr)
library(readxl)
library(haven)

# clear workspace
rm(list = ls())

# set path
dir_base <- "C:/Users/crist/OneDrive/Documentos/GitHub/Large-Devaluations-and-CO2"
dir_raw <- file.path(dir_base, "01-raw-data")
dir_output <- file.path(dir_base, "04-output")

# read data
inflation <- read_excel(file.path(dir_raw, "macroeconomic indicators/Colombia/1.2.5.IPC_Serie_variaciones_IQY.xlsx"), range = "A13:B850")

# rename columns
colnames(inflation) <- c("date", "ipc")

# we add a "-" after the year to make it easier to convert to date
inflation$date <- gsub("([0-9]{4})", "\\1-", inflation$date)

# we declare the date format (xxxx-xx) and convert the date column to date format
inflation$date <- as.Date(paste0(inflation$date, "-01"), format="%Y-%m-%d")
inflation$date <- as.Date(inflation$date, format = "%Y-%m-%d")

# create a new variable called inflation_rate
inflation$inflation_rate <- (inflation$ipc - lag(inflation$ipc,12))/lag(inflation$ipc,12)

# collapse the data to annual frequency
inflation_annual <- inflation %>%
  mutate(year = as.numeric(format(date, "%Y"))) %>%
  group_by(year) %>%
  summarise(inflation_rate = mean(inflation_rate, na.rm = TRUE))

# keep from 1990 till now
inflation_annual <- inflation_annual %>%
  filter(year >= 1990)

# new colnames
colnames(inflation_annual) <- c("year", "inflation_rate_col")

# save the data as dta
write_dta(inflation_annual, file.path(dir_output, "data-stata/macro-indicators/03-inflation_annual_col.dta"))
