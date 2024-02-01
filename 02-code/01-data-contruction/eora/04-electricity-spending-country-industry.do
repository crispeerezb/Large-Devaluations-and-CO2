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
global wd "${dir_base}\01-code"
global dir_temp "${dir_base}\03-temp"
global dir_source "C:\Users\crist\Dropbox Dropbox\Cristóbal Pérez Barraza\A-Large Devaluations and CO2\DataRaw" // note this one is not in the repository
global output "${dir_base}\04-output"




local start_year = 1990
local end_year = 2016

foreach year of numlist `start_year'/`end_year' {

	insheet using "${dir_source}\EORA\Eora26_`year'_bp\Eora26_`year'_bp_T.txt", tab clear
	gen countryXindustry = _n
	tostring countryXindustry, replace
	merge 1:1 countryXindustry using "${dir_temp}\countryXindustry_clean.dta", assert(3) nogen

	* include only electricity inputs, from all countries
	keep if industry == "Electricity, Gas and Water" | industry == "Petroleum, Chemical and Non-Metallic Mineral Products" | industry == "Mining and Quarrying"
	
	drop industry

	* sum input from electricity
	collapse (sum) v1-v4915, fast
	gen one = 1
	reshape long v, i(one) j(countryXindustry)
	drop one
	tostring countryXindustry, replace
	rename v electricity_spending

	* merge data from countryXindustry
	merge 1:1 countryXindustry using "${dir_temp}\countryXindustry_clean.dta", assert(3) nogen

	gen year = `year'

	order country country_code industry year electricity_spending
	
	save "${dir_temp}\electricity-spending\electricity-spending_`year'.dta", replace
	
}


* Then, we append data
cd "${dir_temp}\electricity-spending"
use electricity-spending_1990.dta, clear 

foreach year of numlist 1991/2016 {
    append using electricity-spending_`year'.dta
}




* Finally we merge gross output data to have electricity spending share
merge 1:1 country country_code industry year using "${output}/data-stata/eora/01-gross_output_country-industry.dta", assert(3) nogen
gen electricity_spending_share = electricity_spending/grossoutput

order countryXindustry country country_code industry year electricity_spending grossoutput electricity_spending_share
sort country country_code year industry

rename electricity_spending_share energy_cost_share 
rename electricity_spending energy_spending

save "${output}\data-stata\eora\04-electricity-spending.dta", replace