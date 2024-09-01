# remove everything from the workspace
rm(list=ls())

# load libraries
library(dplyr)
library(ggplot2)
library(tidyr)
library(haven)
library(gridExtra)

# set working directory
setwd("C:/Users/crist/OneDrive/Documentos/GitHub/Large-Devaluations-and-CO2/04-output/data-stata/eam")

# load data from stata format
data <- read_dta("08-EAM-2010-2019.dta")

# define year as date
data <- data %>%
  mutate(year = as.Date(paste0(year, "-01-01")))


##############################################
################# Emissions ##################
##############################################

# create a data set with emissions by year
emissions <- data %>%
  select(year, co2_emission_ton, carbon_emission, fossil_fuel_emission, gas_emission, gross_output, valorven, total_cost, cost_energy, energy_purchased_kwh, salpeyte, invebrta, industrial_output) %>%
  group_by(year) %>%
  summarise(co2_emission = sum(co2_emission_ton),
            carbon_emission = sum(carbon_emission),
            fossil_fuel_emission = sum(fossil_fuel_emission),
            gas_emission = sum(gas_emission),
            gross_output = sum(gross_output),
            valorven = sum(valorven),
            total_cost = sum(total_cost),
            cost_energy = sum(cost_energy),
            energy_purchased_kwh = sum(energy_purchased_kwh),
            salpeyte = mean(salpeyte),
            invebrta = sum(invebrta),
            industrial_output = sum(industrial_output))

# create co2 rate in kg per local currency (NOTE: emissions are in tons)
emissions$co2_rate_gross_output <- (emissions$co2_emission/emissions$gross_output)*1000
emissions$co2_rate_valorven <- (emissions$co2_emission/emissions$valorven)*1000
emissions$co2_rate_total_cost <- (emissions$co2_emission/emissions$total_cost)*1000

# create variable for energy rate (as percentage of total cost)
emissions$energy_rate <- emissions$cost_energy/emissions$total_cost


# check evolution of co2_rate_gross_output, co2_rate_valorven and co2_rate_total_cost in a nice graph
emissions %>%
  gather(key = "variable", value = "value", co2_rate_gross_output, co2_rate_valorven, co2_rate_total_cost) %>%
  ggplot(aes(x = year, y = value, color = variable)) +
  geom_line(size = 1.2) +  # Aumenta el grosor de las líneas
  geom_point(size = 2.5) +  # Agrega puntos en las líneas
  labs(title = "Evolution of CO2 Emissions Rates in EAM",
       x = "Year",
       y = "CO2 Emissions Rate (kg per local currency)") +
  theme_minimal()

# let's check what happend with gross_output and industrial_output (both in same graph)
emissions %>%
  gather(key = "variable", value = "value", gross_output, industrial_output) %>%
  ggplot(aes(x = year, y = value, color = variable)) +
  geom_line(size = 1.2) +  # Aumenta el grosor de las líneas
  geom_point(size = 2.5) +  # Agrega puntos en las líneas
  labs(title = "Evolution of Gross Output and Industrial Output in EAM",
       x = "Year",
       y = "Local Currency") +
  theme_minimal()


# let's check what happend with emissions
emissions %>%
  gather(key = "variable", value = "value", co2_emission, carbon_emission, fossil_fuel_emission, gas_emission) %>%
  ggplot(aes(x = year, y = value, color = variable)) +
  geom_line(size = 1.2) +  # Aumenta el grosor de las líneas
  geom_point(size = 2.5) +  # Agrega puntos en las líneas
  labs(title = "Evolution of Emissions in EAM",
       x = "Year",
       y = "CO2 Emissions (ton)") +
  theme_minimal()

# now check only co2 in log
emissions %>%
  ggplot(aes(x = year, y = log(co2_emission), color = "CO2 Emissions")) +
  geom_line(size = 1.2) +  # Aumenta el grosor de las líneas
  geom_point(size = 2.5) +  # Agrega puntos en las líneas
  labs(title = "Evolution of CO2 Emissions in EAM",
       x = "Year",
       y = "Log CO2 Emissions (ton)") +
  theme_minimal()

# check evolution of energy cost share in a nice graph
emissions %>%
  ggplot(aes(x = year, y = energy_rate)) +
  geom_line(size = 1.2) +
  geom_point(size = 2.5) +
  labs(title = "Evolution of Energy Cost Share in EAM",
       x = "Year",
       y = "Energy Cost Share (as percentage of total cost)") +
  theme_minimal()


# check evolution of energy purchased in a nice graph
emissions %>%
  ggplot(aes(x = year, y = energy_purchased_kwh)) +
  geom_line(size = 1.2) +
  geom_point(size = 2.5) +
  labs(title = "Evolution of Energy Purchased in EAM",
       x = "Year",
       y = "Energy Purchased (kWh)") +
  theme_minimal()

# now create variables for carbon and fossil fuel emissions
emissions$carbon_rate <- (emissions$carbon_emission/emissions$gross_output)*1000
emissions$fossil_fuel_rate <- (emissions$fossil_fuel_emission/emissions$gross_output)*1000
emissions$gas_rate <- (emissions$gas_emission/emissions$gross_output)*1000


#######################################
##### Investment and Employment #######
#######################################

# now we check what happen with investment and employment
production_factor <- data %>% select(year, cost_energy, gross_output, valorven, total_cost, salpeyte, invebrta, employment, industrial_output) %>% 
  group_by(year) %>% 
  summarise(gross_output = sum(gross_output),
            valorven = sum(valorven),
            total_cost = sum(total_cost),
            cost_energy = sum(cost_energy),
            salpeyte = sum(salpeyte),
            invebrta = sum(invebrta),
            employment = sum(employment),
            industrial_output = sum(industrial_output))

# create rates variables
production_factor$salpeyte_rate <- production_factor$salpeyte/production_factor$gross_output
production_factor$invebrta_rate <- production_factor$invebrta/production_factor$gross_output
production_factor$employment_rate <- production_factor$employment/production_factor$gross_output


# check what happend with salary
production_factor %>%
  gather(key = "variable", value = "value", salpeyte_rate) %>%
  ggplot(aes(x = year, y = value, color = variable)) +
  geom_line(size = 1.2) +  
  geom_point(size = 2.5) +
  labs(title = "Evolution of Salary Rate in EAM",
       x = "Year",
       y = "Avarege Salary") +
  theme_minimal()

# now check what happend with salary but in levels
production_factor %>%
  ggplot(aes(x = year, y = salpeyte)) +
  geom_line(size = 1.2) +
  geom_point(size = 2.5) +
  labs(title = "Evolution of Salary in EAM (Mean)",
       x = "Year",
       y = "Local Currency") +
  theme_minimal()


# check what happend with investment
production_factor %>%
  gather(key = "variable", value = "value", invebrta_rate) %>%
  ggplot(aes(x = year, y = value, color = variable)) +
  geom_line(size = 1.2) +  
  geom_point(size = 2.5) +
  labs(title = "Evolution of Gross Investment Rate in EAM",
       x = "Year",
       y = "CO2 Emissions Rate (kg per local currency)") +
  scale_color_manual(values = c("invebrta_rate" = "blue"),
                     labels = c("Gross Investment")) +
  theme_minimal()

# check what happend with employment
production_factor %>%
  gather(key = "variable", value = "value", employment_rate) %>%
  ggplot(aes(x = year, y = value, color = variable)) +
  geom_line(size = 1.2) +  
  geom_point(size = 2.5) +
  labs(title = "Evolution of Employment Rate in EAM",
       x = "Year",
       y = "CO2 Emissions Rate (kg per local currency)") +
  scale_color_manual(values = c("employment_rate" = "green"),
                     labels = c("Employment")) +
  theme_minimal()

