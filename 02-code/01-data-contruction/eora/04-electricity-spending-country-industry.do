/*
*****************************************************
*****************************************************
THIS CODE CREATE A DATA SET WITH ELECTRICITY SPENDING
*****************************************************
*****************************************************
*/


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
global dir_output "${dir_base}\04-output"


*** load data set with gross output and co2 emissions
use "${dir_output}\data-stata\eora\03-co2-emissions-scope1-country-industry.dta"
merge 1:1 country country_code industry year using "${dir_output}\data-stata\eora\04-co2-emissions-scope2-country-industry.dta"

* generate co2 rates for scope 1 and 2
replace co2_rates_scope1 = co2_rates_scope1*1000
gen co2_rates_scope2 = (scope_2_A/grossoutput)*10000

keep country country_code industry year co2_rates_scope1 co2_rates_scope2