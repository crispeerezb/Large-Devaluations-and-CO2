/*
************************************************
************************************************
THIS CODE CREATE A DATA SET WITH ENERGY SPENDING
************************************************
************************************************
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
global dir_source "${dir_base}\01-raw-data"
global dir_temp "${dir_base}\03-temp"
global output "${dir_base}\04-output"



*** merge all data we need ***
use "${output}\data-stata\eora\03-co2-emissions-scope-2-country-industry.dta", clear

* drop rates, just to keep things clear
drop co2_rates_scope1 co2_rates_scope2

merge 1:1 countryXindustry country country_code industry year using "${output}\data-stata\eora\04-electricity-spending.dta",  nogen

* drop rates, just to keep things clear
drop energy_cost_share

* add label
label variable countryXindustry "Code for the country industry combination"
label variable country "Country"
label variable country_code "three digit code for country"
label variable industry "Industrial sector"
label variable year "Period"
label variable grossoutput "Gross output"
label variable co2_scope1 "CO2 emissions from scope 1"
label variable co2_scope2 "CO2 emissions from scope 2"
label variable energy_spending "Energy spending"

save "${output}\data-stata\eora\05-EORA-COUNTRY-INDUSTRY-1990-2016.dta", replace