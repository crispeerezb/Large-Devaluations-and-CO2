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
library(gridExtra)

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
dir_results <- file.path(dir_base, "05-results")

# load data to get graphs
df_countries_co2_rates <- read_dta(file.path(dir_output, "/data-stata/world bank/01-emissions-rates.dta"))

# plot co2 rates across time for those countries that have experienced large devaluations:
# - Colombia (2014)
# - Mexico (1995)
# - Russia (1998)
# - Findland (1993)
# - Island (2014)
# - Malaysa (1997)
# - Indonesia (1998)
# - Japan (1998)
# - Thailand (1998)
# - Korea (1998)
# - Turkey (1994 2001)
# - Brazil (1992 1999 2015)
# - India (1991)

# 1.- plot evolution of CO2 rates for Colombia (scatter plot with lines and a vertical line for 2014)
df_colombia <- df_countries_co2_rates %>%
  filter(Country_Name == "Colombia") %>%
  mutate(Year = as.numeric(Year))

plot_colombia <- ggplot(df_colombia, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 2014, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Colombia",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# 2.- plot evolution of CO2 rates for Mexico (scatter plot with lines and a vertical line for 1995)
df_mexico <- df_countries_co2_rates %>%
  filter(Country_Name == "Mexico") %>%
  mutate(Year = as.numeric(Year))

plot_mexico <- ggplot(df_mexico, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 1995, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Mexico",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# 3.- plot evolution of CO2 rates for Russia (scatter plot with lines and a vertical line for 1998)
df_russia <- df_countries_co2_rates %>%
  filter(Country_Name == "Russian Federation") %>%
  mutate(Year = as.numeric(Year))

plot_russia <- ggplot(df_russia, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 1998, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Russia",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# 4.- plot evolution of CO2 rates for Finland (scatter plot with lines and a vertical line for 1993)
df_finland <- df_countries_co2_rates %>%
  filter(Country_Name == "Finland") %>%
  mutate(Year = as.numeric(Year))

plot_finland <- ggplot(df_finland, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 1993, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Finland",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# 5.- plot evolution of CO2 rates for Island (scatter plot with lines and a vertical line for 2014)
df_island <- df_countries_co2_rates %>%
  filter(Country_Name == "Iceland") %>%
  mutate(Year = as.numeric(Year))

plot_island <- ggplot(df_island, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 2014, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Island",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# 6.- plot evolution of CO2 rates for Malaysia (scatter plot with lines and a vertical line for 1997)
df_malaysia <- df_countries_co2_rates %>%
  filter(Country_Name == "Malaysia") %>%
  mutate(Year = as.numeric(Year))

plot_malaysia <- ggplot(df_malaysia, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 1997, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Malaysia",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()


# 7.- plot evolution of CO2 rates for Indonesia (scatter plot with lines and a vertical line for 1998)
df_indonesia <- df_countries_co2_rates %>%
  filter(Country_Name == "Indonesia") %>%
  mutate(Year = as.numeric(Year))

plot_indonesia <- ggplot(df_indonesia, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 1998, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Indonesia",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# 8.- plot evolution of CO2 rates for Japan (scatter plot with lines and a vertical line for 1998)
df_japan <- df_countries_co2_rates %>%
  filter(Country_Name == "Japan") %>%
  mutate(Year = as.numeric(Year))

plot_japan <- ggplot(df_japan, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 1998, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Japan",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# 9.- plot evolution of CO2 rates for Thailand (scatter plot with lines and a vertical line for 1998)
df_thailand <- df_countries_co2_rates %>%
  filter(Country_Name == "Thailand") %>%
  mutate(Year = as.numeric(Year))

plot_thailand <- ggplot(df_thailand, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 1998, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Thailand",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# 10.- plot evolution of CO2 rates for Korea (scatter plot with lines and a vertical line for 1998)
df_korea <- df_countries_co2_rates %>%
  filter(Country_Name == "Korea, Rep.") %>%
  mutate(Year = as.numeric(Year))

plot_korea <- ggplot(df_korea, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 1998, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Korea",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# 11.- plot evolution of CO2 rates for Turkey (scatter plot with lines and a vertical line for 1994 and 2001)
# df_turkey <- df_countries_co2_rates %>%
#   filter(Country_Name == "Turkey") %>%
#   mutate(Year = as.numeric(Year))
# 
# plot_turkey <- ggplot(df_turkey, aes(x = Year, y = co2_rates)) +
#   geom_line() +
#   geom_point() +
#   geom_vline(xintercept = c(1994, 2001), linetype = "dashed") +
#   labs(title = "CO2 Emissions as a share of GDP PPPs in Turkey",
#        x = "Year",
#        y = "CO2 Emissions as a share of GDP PPPs") +
#   theme_minimal()

# 12.- plot evolution of CO2 rates for Brazil (scatter plot with lines and a vertical line for 1992, 1999, and 2015)
df_brazil <- df_countries_co2_rates %>%
  filter(Country_Name == "Brazil") %>%
  mutate(Year = as.numeric(Year))

plot_brazil <- ggplot(df_brazil, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = c(1992, 1999, 2015), linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in Brazil",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# 13.- plot evolution of CO2 rates for India (scatter plot with lines and a vertical line for 1991)
df_india <- df_countries_co2_rates %>%
  filter(Country_Name == "India") %>%
  mutate(Year = as.numeric(Year))

plot_india <- ggplot(df_india, aes(x = Year, y = co2_rates)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = 1991, linetype = "dashed") +
  labs(title = "CO2 Emissions as a share of GDP PPPs in India",
       x = "Year",
       y = "CO2 Emissions as a share of GDP PPPs") +
  theme_minimal()

# save plots in results folder as pdf
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-colombia.pdf"), plot = plot_colombia, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-mexico.pdf"), plot = plot_mexico, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-russia.pdf"), plot = plot_russia, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-finland.pdf"), plot = plot_finland, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-island.pdf"), plot = plot_island, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-malaysia.pdf"), plot = plot_malaysia, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-indonesia.pdf"), plot = plot_indonesia, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-japan.pdf"), plot = plot_japan, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-thailand.pdf"), plot = plot_thailand, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-korea.pdf"), plot = plot_korea, width = 10, height = 7)
#ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-turkey.pdf"), plot = plot_turkey, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-brazil.pdf"), plot = plot_brazil, width = 10, height = 7)
ggsave(file.path(dir_results, "world bank/statistics/co2-rates-evolution-india.pdf"), plot = plot_india, width = 10, height = 7)

# now let's try to plot all of them in a single pdf
# pdf(file.path(dir_results, "world bank/statistics/co2-rates-evolution-large-devaluations.pdf"), width = 10, height = 7)
# grid.arrange(plot_colombia, plot_mexico, plot_russia, plot_finland, plot_island, plot_malaysia, plot_indonesia, plot_japan, plot_thailand, plot_korea, plot_brazil, plot_india, ncol = 3)
# dev.off()

# we note that letters are too big, let's try to reduce them
plot_colombia <- plot_colombia + theme(text = element_text(size = 5))
plot_mexico <- plot_mexico + theme(text = element_text(size = 5))
plot_russia <- plot_russia + theme(text = element_text(size = 5))
plot_finland <- plot_finland + theme(text = element_text(size = 5))
plot_island <- plot_island + theme(text = element_text(size = 5))
plot_malaysia <- plot_malaysia + theme(text = element_text(size = 5))
plot_indonesia <- plot_indonesia + theme(text = element_text(size = 5))
plot_japan <- plot_japan + theme(text = element_text(size = 5))
plot_thailand <- plot_thailand + theme(text = element_text(size = 5))
plot_korea <- plot_korea + theme(text = element_text(size = 5))
plot_brazil <- plot_brazil + theme(text = element_text(size = 5))
plot_india <- plot_india + theme(text = element_text(size = 5))

pdf(file.path(dir_results, "world bank/statistics/co2-rates-evolution-large-devaluations.pdf"), width = 10, height = 7)
grid.arrange(plot_colombia, plot_mexico, plot_russia, plot_finland, plot_island, plot_malaysia, plot_indonesia, plot_japan, plot_thailand, plot_korea, plot_brazil, plot_india, ncol = 3)
dev.off()




































































































