# Remove everything from the workspace
rm(list = ls())

# Load necessary libraries
library(dplyr)
library(ggplot2)
library(tidyr)
library(haven)
library(gridExtra)
library(lubridate)
library(fixest)
library(stargazer)
library(modelsummary)

####################################################
# 1. Load data for emissions and clean the dataset #
####################################################

# Set base directories
dir_base <- "C:/Users/crist/OneDrive/Documentos/GitHub/Large-Devaluations-and-CO2"
dir_raw <- paste0(dir_base, "/01-raw-data")
dir_output <- paste0(dir_base, "/04-output")
dir_results <- paste0(dir_base, "/05-results/eora/local-projections")

# Load data from Stata format
df_eora <- read_dta(file.path(dir_output, "data-stata", "eora", "06-EORA-COUNTRY-INDUSTRY-1990-2009_V2.dta"))

# Group data by country and year, then summarize emissions and output
df_eora <- df_eora %>%
  group_by(country, country_code, year) %>%
  summarise(
    co2_scope1 = sum(co2_scope1, na.rm = TRUE),
    co2_scope2 = sum(co2_scope2, na.rm = TRUE),
    gross_output = sum(grossoutput_PPP, na.rm = TRUE)
  )

# Calculate CO2 intensity (logarithm of CO2 emissions over gross output)
df_eora$co2_intensity <- log(df_eora$co2_scope1 / df_eora$gross_output)

#####################################
# 2. Load data for financial crises #
#####################################

# Load financial crises data
df_banking_crises <- read_dta(file.path(dir_output, "data-stata", "financial-crisis", "sistemic_banking_crisis.dta"))

################################################
# 3. Add financial crises to emissions dataset #
################################################

# Left join the crises data to the emissions data based on country code and year
df_eora <- df_eora %>%
  left_join(df_banking_crises, by = c("country_code", "year"))

# Remove redundant country column from the merged data
df_eora$country.y <- NULL

# Rename country.x to country for clarity
colnames(df_eora)[1] <- "country"

# Replace NA values with 0 in the crisis event indicator
df_eora$sis_banking_crisis_event[is.na(df_eora$sis_banking_crisis_event)] <- 0

# Rename the crisis event column to "event"
colnames(df_eora)[ncol(df_eora)] <- "event"


############################################
# 4. pen-table data set for countries data #
############################################

# load data set from pen-table
df_pen_table <- read_dta(file.path(dir_raw, "penn_world_tables", "pwt100_temp.dta"))

# just keep variables relevant for the analysis
df_pen_table <- df_pen_table %>% 
  select(country_code, year, lrgdpo, lemp, lrnna)

# add to df_eora
df_eora <- df_eora %>% 
  left_join(df_pen_table, by = c("country_code", "year"))

##########################################
# 5. Local projections for CO2 intensity #
##########################################

# Set the maximum horizon for local projections
max_h <- 6

# Create a list to store the model results
results <- list()

# Create lead variables for CO2 intensity for each horizon h
for (h in 0:max_h) {
  df_eora <- df_eora %>%
    group_by(country) %>%
    arrange(year) %>%
    mutate(!!paste0("co2_intensity_lead_", h) := lead(co2_intensity, n = h))
}

# Estimate the local projection model for each horizon h
for (h in 0:max_h) {
  
  # Specify the model formula
  formula_lp <- as.formula(paste0(
    "co2_intensity_lead_", h, " ~ event + lrgdpo + lemp + lrnna + factor(country) + factor(year)"
  ))
  
  # Estimate the model using fixed effects and cluster robust standard errors at the country level
  model_lp <- feols(formula_lp, data = df_eora, cluster = "country")
  
  # Store the model result in the list
  results[[paste0("h_", h)]] <- model_lp
}

##########################################
# 5. Plot the estimated parameters       #
##########################################

# Extract coefficients and standard errors for the 'event' variable at each horizon h
coefficients_df <- data.frame(
  horizon = 0:max_h,
  beta = sapply(results, function(model) coef(model)["event"]),
  se = sapply(results, function(model) sqrt(vcov(model)["event", "event"]))
)

# Calculate the 95% confidence intervals
coefficients_df <- coefficients_df %>%
  mutate(
    ci_lower = beta - 1.96 * se,
    ci_upper = beta + 1.96 * se
  )

# Plot the coefficients with their confidence intervals
ggplot(coefficients_df, aes(x = horizon, y = beta)) +
  geom_line(aes(y = beta), color = "blue", size = 1.15) +
  geom_line(aes(y = ci_upper), color = "blue", linetype = "dashed", size = 1.15) +
  geom_line(aes(y = ci_lower), color = "blue", linetype = "dashed", size = 1.15) +
  geom_hline(yintercept = 0, linetype = "dashed", size = 1) +
  labs(
    x = "Horizon (years after the crisis)",
    y = "Estimated coefficient beta"
  ) +
  theme_minimal(base_size = 30)

# # Plot the coefficients with their confidence intervals
# ggplot(coefficients_df, aes(x = horizon, y = beta)) +
#   geom_line(color = "blue") +
#   geom_point(color = "blue") +
#   geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, color = "blue") +
#   geom_hline(yintercept = 0, linetype = "dashed") +
#   labs(
#     title = "Effect of Financial Crises on CO2 Intensity",
#     x = "Horizon (years after the crisis)",
#     y = "Estimated coefficient beta"
#   ) +
#   theme_minimal()

# save the plot in result folder
ggsave(file.path(dir_results, "co2_intensity_sys_banking_crises.pdf"), width = 20, height = 10)
