# load libraries
library(dplyr)
library(readr)
library(readxl)
library(haven)

# set path
dir_base <- "C:/Users/crist/OneDrive/Documentos/GitHub/Large-Devaluations-and-CO2"
dir_raw <- file.path(dir_base, "01-raw-data")
dir_output <- file.path(dir_base, "04-output")

# read data
exchange_data <- read_excel(file.path(dir_raw, "macroeconomic indicators/Colombia/exchange rate.xlsx"), 
                            sheet = "Sheet1", range = "A8:B11854")

# change colnames
colnames(exchange_data) <- c("date", "exchange_rate")

# first declare the date column as a date 
exchange_data$date <- as.Date(exchange_data$date, format = "%Y/%m/%d")

# collapse data by year
exchange_data <- exchange_data %>%
  mutate(year = as.numeric(format(date, "%Y"))) %>%
  group_by(year) %>%
  summarise(exchange_rate = mean(exchange_rate, na.rm = TRUE))

# export as dta file
write_dta(exchange_data, file.path(dir_output, "data-stata/macro-indicators/01-exchange_rate_col_usd.dta"))