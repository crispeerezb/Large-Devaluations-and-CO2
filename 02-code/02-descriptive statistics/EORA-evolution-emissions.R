# remove everything from the workspace
rm(list=ls())

# load libraries
library(dplyr)
library(ggplot2)
library(tidyr)
library(haven)
library(gridExtra)

# set working directory
setwd("C:/Users/crist/OneDrive/Documentos/GitHub/Large-Devaluations-and-CO2/04-output/data-stata/eora")

# load data from stata format
data <- read_dta("03-co2-emissions-scope-2-country-industry.dta")

# create a new variable that i will call ln_emissions
data$ln_emissions <- log(data$co2_scope1 + data$co2_scope2)
data$ln_emissions[data$ln_emissions == -Inf] <- 0

# create scope 1 and 2 in log
data$ln_co2_scope1 <- log(data$co2_scope1)
data$ln_co2_scope2 <- log(data$co2_scope2)

data$ln_co2_scope1[data$ln_co2_scope1 == -Inf] <- 0
data$ln_co2_scope2[data$ln_co2_scope2 == -Inf] <- 0

# keep variables that i will need only
data <- data %>% select(country_code, industry, year, 
                        ln_emissions, ln_co2_scope1, 
                        ln_co2_scope2, co2_scope1, co2_scope2)

# filter data only before 2009
data <- data %>% filter(year < 2009)

# data in country level
data_country <- data %>% group_by(country_code, year) %>%
  summarise(co2_scope1 = sum(co2_scope1),
            co2_scope2 = sum(co2_scope2))

data_country$ln_emissions <- log(data_country$co2_scope1 + data_country$co2_scope2)
data_country$ln_emissions[data_country$ln_emissions == -Inf] <- 0

data_country$ln_co2_scope1 <- log(data_country$co2_scope1)
data_country$ln_co2_scope2 <- log(data_country$co2_scope2)

data_country$ln_co2_scope1[data_country$ln_co2_scope1 == -Inf] <- 0
data_country$ln_co2_scope2[data_country$ln_co2_scope2 == -Inf] <- 0


#################################
# Argentina emissions evolution #
#################################

# see evolution for industries in "ARG" country. We do it in different plots, because we have a lot of industries
# add an x-line in the year of the devaluation 2002
data %>%
  filter(country_code == "ARG") %>%
  ggplot(aes(x = year, y = ln_co2_scope1, color = industry)) +
  geom_line(size = 1.2) +  
  geom_vline(xintercept = 2002, linetype = "dashed", size = 1) +  
  facet_wrap(~industry, scales = "free_y") +
  theme_minimal(base_size = 15) + 
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    legend.position = "none",  
    strip.text = element_text(size = 10, face = "bold")  
  ) +
  labs(
    title = "Evolución de las Emisiones de CO2 por Industria en Argentina",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# now we see the evolution but for country level (group by country and year)
# add an x-line in the year of the devaluation 2002
data_country %>% 
  filter(country_code == "ARG") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line(size = 1.2) +  
  geom_point(size = 2) +  
  geom_vline(xintercept = 2002, linetype = "dashed", size = 1) +  
  theme_minimal(base_size = 15) + 
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    legend.position = "none"  
  ) +
  labs(
    title = "Evolución de las Emisiones de CO2 en Argentina",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )


#############################
# Korea emissions evolution #
#############################

# see evolution for industries in "KOR" country. We do it in different plots, because we have a lot of industries
# add an x-line in the year of the devaluation 1999
data %>%
  filter(country_code == "KOR") %>%
  ggplot(aes(x = year, y = ln_emissions, color = industry)) +
  geom_line(size = 1.2) +  
  geom_vline(xintercept = 1999, linetype = "dashed", size = 1) +  
  facet_wrap(~industry, scales = "free_y") +
  theme_minimal(base_size = 15) + 
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    legend.position = "none",  
    strip.text = element_text(size = 10, face = "bold")  
  ) +
  labs(
    title = "Evolución de las Emisiones de CO2 por Industria en Corea del Sur",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# now we see the evolution but for country level (group by country and year)
# add an x-line in the year of the devaluation 1999
data_country %>% 
  filter(country_code == "KOR") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line(size = 1.2) +  
  geom_point(size = 2) +  
  geom_vline(xintercept = 1999, linetype = "dashed", size = 1) +  
  theme_minimal(base_size = 15) + 
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    legend.position = "none"  
  ) +
  labs(
    title = "Evolución de las Emisiones de CO2 en Corea del Sur",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )


##############################
# Turkey emissions evolution #
##############################

# see evolution for industries in "TUR" country. We do it in different plots, because we have a lot of industries
# add an x-line in the year of the devaluation 1994 and 2001
data %>%
  filter(country_code == "TUR") %>%
  ggplot(aes(x = year, y = ln_emissions, color = industry)) +
  geom_line(size = 1.2) +  
  geom_vline(xintercept = 1994, linetype = "dashed", size = 1) +  
  geom_vline(xintercept = 2001, linetype = "dashed", size = 1) +  
  facet_wrap(~industry, scales = "free_y") +
  theme_minimal(base_size = 15) + 
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    legend.position = "none",  
    strip.text = element_text(size = 10, face = "bold")  
  ) +
  labs(
    title = "Evolución de las Emisiones de CO2 por Industria en Turquía",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# now we see the evolution but for country level (group by country and year)
# add an x-line in the year of the devaluation 1994 and 2001
data_country %>% 
  filter(country_code == "TUR") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line(size = 1.2) +  
  geom_point(size = 2) +  
  geom_vline(xintercept = 1994, linetype = "dashed", size = 1) +  
  geom_vline(xintercept = 2001, linetype = "dashed", size = 1) +  
  theme_minimal(base_size = 15) + 
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    legend.position = "none"  
  ) +
  labs(
    title = "Evolución de las Emisiones de CO2 en Turquía",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )


##############################
# Mexico emissions evolution #
##############################

# see evolution for industries in "MEX" country. We do it in different plots, because we have a lot of industries
# add an x-line in the year of the devaluation 1995
data %>%
  filter(country_code == "MEX") %>%
  ggplot(aes(x = year, y = ln_emissions, color = industry)) +
  geom_line(size = 1.2) +  
  geom_vline(xintercept = 1995, linetype = "dashed", size = 1) +  
  facet_wrap(~industry, scales = "free_y") +
  theme_minimal(base_size = 15) + 
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    legend.position = "none",  
    strip.text = element_text(size = 10, face = "bold")  
  ) +
  labs(
    title = "Evolución de las Emisiones de CO2 por Industria en México",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# now we see the evolution but for country level (group by country and year)
# add an x-line in the year of the devaluation 1995
data_country %>% 
  filter(country_code == "MEX") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line(size = 1.2) +  
  geom_point(size = 2) +  
  geom_vline(xintercept = 1995, linetype = "dashed", size = 1) +  
  theme_minimal(base_size = 15) + 
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    legend.position = "none"  
  ) +
  labs(
    title = "Evolución de las Emisiones de CO2 en México",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )


################################################################################
####### Country level analysis for all countries with devaluations #############
################################################################################


# now we make one plot for each country with its respective devaluation year and then make a grid with all of them

# country_code=="ARG" and year==2002
# country_code=="MEX" and year==1995
# country_code=="RUS" and year==1998
# country_code=="FIN" and year==1993
# country_code=="ISL" and year==2008
# country_code=="MYS" and year==1997
# country_code=="IDN" and year==1998
# country_code=="THA" and year==1998
# country_code=="KOR" and year==1998
# country_code=="TUR" and year==1994
# country_code=="TUR" and year==2001
# country_code=="BRA" and year==1999
# country_code=="IND" and year==1991
# country_code=="COL" and year==2014

# drop all plots before we start
dev.off()

#############################
# (1) scope 1 and 2 analysis #
#############################

# ARG
p1 <- data_country %>% 
  filter(country_code == "ARG") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +
  geom_point() +  
  geom_vline(xintercept = 2002, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) + 
  labs(
    title = "Argentina",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# MEX
p2 <- data_country %>% 
  filter(country_code == "MEX") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1995, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Mexico",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# RUS
p3 <- data_country %>% 
  filter(country_code == "RUS") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1998, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Russia",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# FIN
p4 <- data_country %>% 
  filter(country_code == "FIN") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1993, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Finland",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# ISL
# p5 <- data_country %>% 
#   filter(country_code == "ISL") %>%
#   ggplot(aes(x = year, y = ln_emissions)) +
#   geom_line() +  
#   geom_point() +  
#   geom_vline(xintercept = 2008, linetype = "dashed", size = 1) +  
#   theme_minimal(base_size = 15) + 
#   theme(
#     axis.text.x = element_text(angle = 90, hjust = 1),
#     legend.position = "none"  
#   ) +
#   labs(
#     title = "Evolución de las Emisiones de CO2 en Islandia",
#     x = "Año",
#     y = "Logaritmo de Emisiones"
#   )

# MYS
p6 <- data_country %>% 
  filter(country_code == "MYS") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1997, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Malaysia",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# IDN
p7 <- data_country %>% 
  filter(country_code == "IDN") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1998, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Indonesia",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# THA
p8 <- data_country %>% 
  filter(country_code == "THA") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1998, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Thailand",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# KOR
p9 <- data_country %>% 
  filter(country_code == "KOR") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1998, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Korea",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# TUR
p10 <- data_country %>% 
  filter(country_code == "TUR") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1994, linetype = "dashed", size = 0.5) +  
  geom_vline(xintercept = 2001, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Turkey",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# BRA
p11 <- data_country %>% 
  filter(country_code == "BRA") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1999, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Brazil",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# IND
p12 <- data_country %>% 
  filter(country_code == "IND") %>%
  ggplot(aes(x = year, y = ln_emissions)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1991, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "India",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# COL
# p13 <- data_country %>% 
#   filter(country_code == "COL") %>%
#   ggplot(aes(x = year, y = ln_emissions)) +
#   geom_line() +  
#   geom_point() +  
#   geom_vline(xintercept = 2014, linetype = "dashed", size = 1) +  
#   theme_minimal(base_size = 15) +
#   labs(
#     title = "Colombia",
#     x = "Año",
#     y = "Logaritmo de Emisiones"
#   )

# now we make a grid with all the plots
p1 <- p1 + theme(text = element_text(size = 8))
p2 <- p2 + theme(text = element_text(size = 8))
p3 <- p3 + theme(text = element_text(size = 8))
p4 <- p4 + theme(text = element_text(size = 8))
#p5 <- p5 + theme(text = element_text(size = 8))
p6 <- p6 + theme(text = element_text(size = 8))
p7 <- p7 + theme(text = element_text(size = 8))
p8 <- p8 + theme(text = element_text(size = 8))
p9 <- p9 + theme(text = element_text(size = 8))
p10 <- p10 + theme(text = element_text(size = 8))
p11 <- p11 + theme(text = element_text(size = 8))
p12 <- p12 + theme(text = element_text(size = 8))
                   
  
grid.arrange(
  p1, p2, p3, p4, p6, p7, p8, p9, p10, p11, p12, ncol = 3
)


#########################
# (2) scope 1 analysis #
#########################

# ARG
p1 <- data_country %>% 
  filter(country_code == "ARG") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +
  geom_point() +  
  geom_vline(xintercept = 2002, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) + 
  labs(
    title = "Argentina",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# MEX
p2 <- data_country %>% 
  filter(country_code == "MEX") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1995, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Mexico",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# RUS
p3 <- data_country %>% 
  filter(country_code == "RUS") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1998, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Russia",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# FIN
p4 <- data_country %>% 
  filter(country_code == "FIN") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1993, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Finland",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# ISL
# p5 <- data_country %>%
#   filter(country_code == "ISL") %>%
#   ggplot(aes(x = year, y = ln_co2_scope1)) +
#   geom_line() +
#   geom_point() +
#   geom_vline(xintercept = 2008, linetype = "dashed", size = 0.5) +
#   theme_minimal(base_size = 15) +
#   labs(
#     title = "Iceland",
#     x = "Año",
#     y = "Logaritmo de Emisiones"
#   )

# MYS
p6 <- data_country %>% 
  filter(country_code == "MYS") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1997, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Malaysia",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# IDN
p7 <- data_country %>% 
  filter(country_code == "IDN") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1998, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Indonesia",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# THA
p8 <- data_country %>% 
  filter(country_code == "THA") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1998, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Thailand",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# KOR
p9 <- data_country %>% 
  filter(country_code == "KOR") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1998, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Korea",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# TUR
p10 <- data_country %>% 
  filter(country_code == "TUR") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1994, linetype = "dashed", size = 0.5) +  
  geom_vline(xintercept = 2001, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Turkey",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# BRA
p11 <- data_country %>% 
  filter(country_code == "BRA") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1999, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "Brazil",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# IND
p12 <- data_country %>% 
  filter(country_code == "IND") %>%
  ggplot(aes(x = year, y = ln_co2_scope1)) +
  geom_line() +  
  geom_point() +  
  geom_vline(xintercept = 1991, linetype = "dashed", size = 0.5) +  
  theme_minimal(base_size = 15) +
  labs(
    title = "India",
    x = "Año",
    y = "Logaritmo de Emisiones"
  )

# COL
# p13 <- data_country %>%
#   filter(country_code == "COL") %>%
#   ggplot(aes(x = year, y = ln_co2_scope1)) +
#   geom_line() +
#   geom_point() +
#   geom_vline(xintercept = 2014, linetype = "dashed", size = 0.5) +
#   theme_minimal(base_size = 15) +
#   labs(
#     title = "Colombia",
#     x = "Año",
#     y = "Logaritmo de Emisiones"
#   )

# now we make a grid with all the plots
p1 <- p1 + theme(text = element_text(size = 8))
p2 <- p2 + theme(text = element_text(size = 8))
p3 <- p3 + theme(text = element_text(size = 8))
p4 <- p4 + theme(text = element_text(size = 8))
#p5 <- p5 + theme(text = element_text(size = 8))
p6 <- p6 + theme(text = element_text(size = 8))
p7 <- p7 + theme(text = element_text(size = 8))
p8 <- p8 + theme(text = element_text(size = 8))
p9 <- p9 + theme(text = element_text(size = 8))
p10 <- p10 + theme(text = element_text(size = 8))
p11 <- p11 + theme(text = element_text(size = 8))
p12 <- p12 + theme(text = element_text(size = 8))

scope_1_grid_country <- grid.arrange(
  p1, p2, p3, p4, p6, p7, p8, p9, p10, p11, p12, ncol = 3
)


                   
                   

























