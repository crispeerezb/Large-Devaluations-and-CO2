# remove everything from the workspace
rm(list=ls())

# load libraries
library(dplyr)
library(ggplot2)
library(tidyr)
library(haven)
library(gridExtra)
library(lubridate)
library(fixest)
library(stargazer)
library(modelsummary)

# set working directory
setwd("C:/Users/crist/OneDrive/Documentos/GitHub/Large-Devaluations-and-CO2/04-output/data-stata/eam")

# load data from stata format
df_eam <- read_dta("08-EAM-2010-2019.dta")

# define some variables in proper format
df_eam$id_firm <- as.character(df_eam$id_firm)
df_eam$ciiu <- as.character(df_eam$ciiu)

# just to keep things clean, let's remove data before 2012
df_eam <- df_eam %>%
  filter(year >= 2012)

# Aggregate the data by id_firm, ciiu, and year
df_eam <- df_eam %>%
  group_by(id_firm, ciiu, year) %>%
  summarise(
    valorcx = sum(valorcx, na.rm = TRUE),
    gross_output = sum(gross_output, na.rm = TRUE),
    valorven = sum(valorven, na.rm = TRUE),
    total_cost = sum(total_cost, na.rm = TRUE),
    industrial_output = sum(industrial_output, na.rm = TRUE),
    invebrta = sum(invebrta, na.rm = TRUE),
    cost_energy = sum(cost_energy, na.rm = TRUE),
    #salpeyte = sum(salpeyte, na.rm = TRUE),
    co2_emission_ton = sum(co2_emission_ton, na.rm = TRUE),
    employment = sum(employment, na.rm = TRUE),
    energy_purchased_kwh = sum(energy_purchased_kwh, na.rm = TRUE),
    energy_generated_kwh = sum(energy_generated_kwh, na.rm = TRUE),
    carbon_emission = sum(carbon_emission, na.rm = TRUE),
    fuel_emission = sum(fuel_emission, na.rm = TRUE),
    gas_emission = sum(gas_emission, na.rm = TRUE),
    .groups = 'drop' # Drop grouping afterwards
  )

# ============================================================================ #
# ================== 1. Shift-share instrument construction ================== #
# ============================================================================ #

###########################################
# 1.1. Calculate the baseline year shares #
###########################################

# Filter for the baseline year (2012)
baseline_data <- df_eam %>%
  filter(year == 2012)

# Calculate total gross output by industry in 2012
firm_gross_output_2012 <- baseline_data %>%
  group_by(id_firm) %>%
  summarise(total_gross_output = sum(gross_output, na.rm = TRUE))

# Merge total industry output back into baseline data
baseline_shares <- baseline_data %>%
  left_join(firm_gross_output_2012, by = "id_firm") %>%
  mutate(s_ij = gross_output / total_gross_output) %>%
  select(id_firm, ciiu, s_ij)


#####################################################
# 1.2. Calculate total imports by industry and year #
#####################################################

# Calculate total imports by industry and year
industry_imports <- df_eam %>%
  group_by(ciiu, year) %>%
  summarise(total_imports = sum(valorcx, na.rm = TRUE))


# Calculate percentage change in imports (import shock)
industry_import_shocks <- industry_imports %>%
  arrange(ciiu, year) %>%
  group_by(ciiu) %>%
  mutate(Z_jt = (total_imports - lag(total_imports)) / lag(total_imports)) %>%
  filter(!is.na(Z_jt)) # Remove the first year since it won't have a lag



#############################################
# 1.3. Calculate the shift-share instrument #
#############################################

# Merge baseline production shares with full firm data
firm_data_with_shares <- df_eam %>%
  left_join(baseline_shares, by = c("id_firm", "ciiu"))

# Merge the firm-level data with the industry-level import shocks
firm_data_with_shocks <- firm_data_with_shares %>%
  left_join(industry_import_shocks, by = c("ciiu", "year"))

# Construct the shift-share instrument for each firm
firm_data_with_shocks <- firm_data_with_shocks %>%
  mutate(shift_share_Z_it = s_ij * Z_jt)

# View the final dataset with the shift-share instrument
head(firm_data_with_shocks)


# =============================================================== #
# ================== 2. Shift-share estimation ================== #
# =============================================================== #


################################
# 2.1 prepare data to estimate #
################################

# Ensure there are no missing values in the variables of interest
df_final <- firm_data_with_shocks %>%
  filter(!is.na(co2_emission_ton) & !is.na(shift_share_Z_it))

# agregate the data by id_firm and year
df_final <- df_final %>%
  group_by(id_firm, year) %>%
  summarise(
    gross_output = sum(gross_output, na.rm = TRUE),
    total_cost = sum(total_cost, na.rm = TRUE),
    invebrta = sum(invebrta, na.rm = TRUE),
    cost_energy = sum(cost_energy, na.rm = TRUE),
    valorven = sum(valorven, na.rm = TRUE),
    co2_emission_ton = sum(co2_emission_ton, na.rm = TRUE),
    shift_share_Z_it = sum(shift_share_Z_it, na.rm = TRUE),
    industrial_output = sum(industrial_output, na.rm = TRUE),
    employment = sum(employment, na.rm = TRUE),
    energy_purchased_kwh = sum(energy_purchased_kwh, na.rm = TRUE),
    energy_generated_kwh = sum(energy_generated_kwh, na.rm = TRUE),
    carbon_emission = sum(carbon_emission, na.rm = TRUE),
    fuel_emission = sum(fuel_emission, na.rm = TRUE),
    gas_emission = sum(gas_emission, na.rm = TRUE),
    .groups = 'drop' # Drop grouping afterwards
  )

# drop those firms that have cero as gross output
df_final <- df_final %>% filter(gross_output != 0)


# drop those firms that has cero in total_cost, invebrta, valorven, industrial_output
#df_final <- df_final %>% filter(total_cost != 0, invebrta != 0, valorven != 0, industrial_output != 0)

# balance panel, this is: conserve only firms that have data for all years
df_final <- df_final %>%
  group_by(id_firm) %>%
  filter(n() == n_distinct(year)) %>%
  ungroup()

# Calculate CO2 intensity in kg per unit of output
df_final <- df_final %>%
  mutate(co2_intensity = (co2_emission_ton*1000) / gross_output)


# export data set to stata
write_dta(df_final, "09-EAM-2012-2019-Shift-Share.dta")

# # Log-transform CO2 intensity
# df_final <- df_final %>%
#   mutate(log_co2_intensity = log(co2_intensity + 1))  # Add 1 to avoid log(0) errors
# 
# # sort the data
# df_final <- df_final %>%
#   arrange(id_firm, year)
# 
# # note some other erros in the data: some firms have negative in sales, they are removed, since only 2 firms have this problem
# df_final <- df_final %>% filter(valorven > 0)
# 
# 
# 
# # let's define variables in log and add a small number to avoid log(0)
# df_final <- df_final %>%
#   mutate(log_total_cost = log(total_cost + 0.00001),
#          log_valorven = log(valorven + 0.00001),
#          log_industrial_output = log(industrial_output + 0.00001)) # Add 1 to avoid log(0) errors
# 
# # note some other erros in the data: some firms have negative values in  invebrta, we change scale so minum is 0
# df_final$log_invebrta <- log(df_final$invebrta - min(df_final$invebrta, na.rm = TRUE) + 1)
# 
# # note some other erros in the data: some firms have negative values in  shift_share_Z_it, we change scale so minum is 0
# df_final$log_shift_share_Z_it <- log(df_final$shift_share_Z_it - min(df_final$shift_share_Z_it, na.rm = TRUE) + 1)
# 
# #########################################################
# # 2.2. Estimate the model with different especificatios #
# #########################################################
# 
# 
# # version of the model for co2 intensity: all variables in levels
# model_co2_intensity_levels <- feols(co2_intensity ~ shift_share_Z_it +
#                                       industrial_output +
#                                       employment + 
#                                       invebrta| id_firm + year, data = df_final)
# 
# etable(model_co2_intensity_levels, 
#        cluster = "id_firm",
#        digits = 3,
#        fitstat = c("r2", "n"),
#        style.tex = TRUE, 
#        title = "Carbon Emissions",
#        se = "cluster")
# 
# 
# # version of the model for energy purchased: all variables in levels
# model_energy_puchased <- feols(energy_purchased_kwh ~ shift_share_Z_it +
#                                 industrial_output +
#                                 employment + 
#                                 invebrta| id_firm + year, data = df_final)
# 
# etable(model_energy_puchased, 
#        cluster = "id_firm",
#        digits = 3,
#        fitstat = c("r2", "n"),
#        style.tex = TRUE, 
#        title = "Carbon Emissions",
#        se = "cluster")
# 
# # emission
# model_emissions_co2 <- feols(co2_emission_ton ~ shift_share_Z_it +
#                               industrial_output +
#                               employment + 
#                               invebrta| id_firm + year, data = df_final)
# 
# etable(model_emissions_co2, 
#        cluster = "id_firm",
#        digits = 3,
#        fitstat = c("r2", "n"),
#        style.tex = TRUE, 
#        title = "Carbon Emissions",
#        se = "cluster")
# 
# # fuel emission
# model_fuel_emissions <- feols(fuel_emission ~ shift_share_Z_it +
#                               industrial_output +
#                               employment + 
#                               invebrta| id_firm + year, data = df_final)
# 
# etable(model_fuel_emissions, 
#        cluster = "id_firm",
#        digits = 3,
#        fitstat = c("r2", "n"),
#        style.tex = TRUE, 
#        title = "Carbon Emissions",
#        se = "cluster")
# 
# # gas emission
# model_gas_emissions <- feols(gas_emission ~ shift_share_Z_it +
#                               industrial_output +
#                               employment + 
#                               invebrta| id_firm + year, data = df_final)
# 
# etable(model_gas_emissions, 
#        cluster = "id_firm",
#        digits = 3,
#        fitstat = c("r2", "n"),
#        style.tex = TRUE, 
#        title = "Carbon Emissions",
#        se = "cluster")
# 
# 
# # carbon emission
# model_carbon_emissions <- feols(carbon_emission ~ shift_share_Z_it +
#                                 industrial_output +
#                                 employment + 
#                                 invebrta| id_firm + year, data = df_final)
# 
# etable(model_carbon_emissions, 
#        cluster = "id_firm",
#        digits = 3,
#        fitstat = c("r2", "n"),
#        style.tex = TRUE, 
#        title = "Carbon Emissions",
#        se = "cluster")












