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
    energy_consumed_kwh = sum(energy_consumed_kwh, na.rm = TRUE),
    energy_sold_kwh = sum(energy_sold_kwh, na.rm = TRUE),
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
  mutate(Z_jt = log(total_imports+1) - log(lag(total_imports)+1)) %>%
  filter(!is.na(Z_jt)) # Remove the first year since it won't have a lag

# Then also use production as another shock
industry_production <- df_eam %>%
  group_by(ciiu, year) %>%
  summarise(total_production = sum(gross_output, na.rm = TRUE))

# Calculate percentage change in production (production shock)
industry_production_shocks <- industry_production %>%
  arrange(ciiu, year) %>%
  group_by(ciiu) %>%
  mutate(S_jt = log(total_production+1) - log(lag(total_production)+1)) %>%
  filter(!is.na(S_jt)) # Remove the first year since it won't have a lag

#############################################
# 1.3. Calculate the shift-share instrument #
#############################################

# Merge baseline production shares with full firm data
firm_data_with_shares <- df_eam %>%
  left_join(baseline_shares, by = c("id_firm", "ciiu"))

# Merge the firm-level data with the industry-level import shocks
firm_data_with_shocks <- firm_data_with_shares %>%
  left_join(industry_import_shocks, by = c("ciiu", "year"))

# Merge the firm-level data with the industry-level production shocks
firm_data_with_shocks <- firm_data_with_shocks %>%
  left_join(industry_production_shocks, by = c("ciiu", "year"))

# Construct the shift-share instrument for each firm
firm_data_with_shocks <- firm_data_with_shocks %>%
  mutate(shift_share_Z_it = s_ij * Z_jt,
         shift_share_S_it = s_ij * S_jt)

# =============================================================== #
# ================== 2. Shift-share estimation ================== #
# =============================================================== #


################################
# 2.1 prepare data to estimate #
################################

# agregate the data by id_firm and year
df_final <- firm_data_with_shocks %>%
  group_by(id_firm, year) %>%
  summarise(
    gross_output = sum(gross_output, na.rm = TRUE),
    total_cost = sum(total_cost, na.rm = TRUE),
    invebrta = sum(invebrta, na.rm = TRUE),
    cost_energy = sum(cost_energy, na.rm = TRUE),
    valorven = sum(valorven, na.rm = TRUE),
    co2_emission_ton = sum(co2_emission_ton, na.rm = TRUE),
    shift_share_Z_it = sum(shift_share_Z_it, na.rm = TRUE),
    shift_share_S_it = sum(shift_share_S_it, na.rm = TRUE),
    industrial_output = sum(industrial_output, na.rm = TRUE),
    employment = sum(employment, na.rm = TRUE),
    energy_purchased_kwh = sum(energy_purchased_kwh, na.rm = TRUE),
    energy_generated_kwh = sum(energy_generated_kwh, na.rm = TRUE),
    energy_consumed_kwh = sum(energy_consumed_kwh, na.rm = TRUE),
    energy_sold_kwh = sum(energy_sold_kwh, na.rm = TRUE),
    carbon_emission = sum(carbon_emission, na.rm = TRUE),
    fuel_emission = sum(fuel_emission, na.rm = TRUE),
    gas_emission = sum(gas_emission, na.rm = TRUE),
    valorcx = sum(valorcx, na.rm = TRUE),
    .groups = 'drop' # Drop grouping afterwards
  )

# to handle megative and zero values in invebrta, we use Hyperbolic Sine (IHS):
df_final$ln_invebrta <- log(df_final$invebrta + sqrt(df_final$invebrta^2 + 1))

# Calculate CO2 intensity in kg per unit of output (change)
df_final$co2_emission <- df_final$co2_emission_ton * 1000

# drop firms with zero gross output
df_final <- df_final %>%
  filter(gross_output != 0)


# generate different versions of co2 intensity
delta <- 1

df_final <- df_final %>%
  arrange(id_firm, year) %>%
  mutate(
    # version 1
    ln_co2_intensity = log((co2_emission + delta) / (gross_output + delta)),
    
    # version 3
    intensity_ratio = co2_emission / gross_output,
    ln_co2_intensity_v2 = log(intensity_ratio + sqrt(intensity_ratio^2 + 1)),
    
    # version 4
    ln_co2_intensity_v3 = log(co2_emission + delta) - log(gross_output + delta)
  )

# generate variation of co2 intensity
df_final <- df_final %>%
  arrange(id_firm, year) %>%
  group_by(id_firm) %>%
  mutate(
    ln_co2_intensity_diff = ln_co2_intensity - lag(ln_co2_intensity),
    ln_co2_emission_diff = log(co2_emission + delta) - log(lag(co2_emission) + delta),
    ln_energy_purchased_kwh_diff = log(energy_purchased_kwh + delta) - log(lag(energy_purchased_kwh) + delta),
    ln_energy_generated_kwh_diff = log(energy_generated_kwh + delta) - log(lag(energy_generated_kwh) + delta),
    ln_energy_consumed_kwh_diff = log(energy_consumed_kwh + delta) - log(lag(energy_consumed_kwh) + delta),
    ln_energy_sold_kwh_diff = log(energy_sold_kwh + delta) - log(lag(energy_sold_kwh) + delta),
    ln_gross_output_diff = log(gross_output + delta) - log(lag(gross_output) + delta),
    ln_labour_diff = log(employment + delta) - log(lag(employment) + delta),
    ln_invebrta_diff = ln_invebrta - lag(ln_invebrta),
    ln_total_cost_diff = log(total_cost + delta) - log(lag(total_cost) + delta),
    ln_cost_energy_diff = log(cost_energy + delta) - log(lag(cost_energy) + delta)
  ) %>%
  ungroup()

# we balance panel and drop those firms that i can not follow over time
df_final <- df_final %>%
  group_by(id_firm) %>%
  filter(n() == 8) %>%
  ungroup()


# export data set to stata
write_dta(df_final, "09-EAM-2012-2019-Shift-Share.dta")
