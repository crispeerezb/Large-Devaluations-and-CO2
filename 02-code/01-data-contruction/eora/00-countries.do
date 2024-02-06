***** CODE FOR COUNTRIES RELEVANT *****

*** set working dictory ***
clear
global usuario "CP"
{
	if "$usuario" == "EZ" {
		global dir_base "change here"
	}
	if "$usuario" == "CP" {
		global dir_base "C:\Users\crist\OneDrive\Documentos\GitHub\Large-Devaluations-and-CO2"
	}
	if "$usuario" == "J" {
		global dir_base "change here"
	}
}


*** set path where i store the data ***
global wd "${dir_base}\01-code"
global dir_temp "${dir_base}\03-temp"
global output "${dir_base}\04-output"


*** load data set ***
use "${output}\data-stata\eora\04-electricity-spending.dta", clear

keep country country_code
duplicates drop

save "${output}\data-stata\eora\00-countries", replace