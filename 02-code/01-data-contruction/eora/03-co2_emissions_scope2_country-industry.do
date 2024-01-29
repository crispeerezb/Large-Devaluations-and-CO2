/*
****************************************************************************
****************************************************************************
THIS CODE CREATE A DATA SET WITH CO2 (SCOPE 2) EMISSIONS BY COUNTRY-INDUSTRY
****************************************************************************
****************************************************************************
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


/************
Observations:
*************

1) Note that the data used here isn't in the GitHub repository since this data is too big

*/

local start_year = 2001
local end_year = 2016

foreach year of numlist `start_year'/`end_year' {

	insheet using "${dir_source}\EORA\Eora26_`year'_bp\Eora26_`year'_bp_T.txt", tab clear
	gen countryXindustry = _n
	tostring countryXindustry, replace
	merge 1:1 countryXindustry using "${dir_temp}\countryXindustry_clean.dta", assert(3) nogen

	* include only electricity inputs, from all countries
	keep if industry == "Electricity, Gas and Water"
	bysort country: assert _N == 1
	drop countryXindustry

	* country and industry are for the input, countryXindustry is the output
	reshape long v, i(country industry) j(countryXindustry_output)
	rename v electricity_spending

	* merge in co2 rate for each input industry (utilities) and country
	* m:1 because electricity in one country supplies production in many
	* keep(3) because we don't want input industries besides electricity
	merge m:1 country industry using "${dir_temp}/co2-emissions-scope-1/co2-emissions-country-industry_`year'.dta", keepusing(co2_rates_scope1) assert(2 3) keep(3) nogen

	gen co2_scope2 = electricity_spending * co2_rates_scope1

	* sum across different countries' electricity used for prodution
	* (though almost all is domestic), within output countryXindustry
	collapse (sum) co2_scope2, by(countryXindustry_output)
	rename countryXindustry_output countryXindustry
	tostring countryXindustry, replace
	merge 1:1 countryXindustry using "${dir_temp}\countryXindustry_clean.dta", assert(3) nogen

	merge 1:1 countryXindustry using "${dir_temp}\gross-output\grossoutput_temp`year'", keepusing(grossoutput) assert(3) nogen
	merge m:1 country industry using "${dir_temp}\co2-emissions-scope-1\co2-emissions-country-industry_`year'.dta", keepusing(co2_rates_scope1 scope_1_A) assert(2 3) keep(3) nogen

	* Just change name to keep data more organized
	rename scope_1_A co2_scope1 
	
	* Now we have co2 rates for scope 1 in tons
	replace co2_rates_scope1 = co2_rates_scope1*1000
	gen co2_rates_scope2 = (co2_scope2/grossoutput)*1000
	
	* Here we have everything in tons
	replace co2_scope1 = co2_scope1*1000
	replace co2_scope2 = co2_scope2*1000
	
	gen year = `year'
	
	save "${dir_temp}\co2-emissions-scope-2\co2-emissions-country-industry_`year'.dta", replace

}


* Finally we append data
cd "${dir_temp}\co2-emissions-scope-2"
use co2-emissions-country-industry_1990.dta, clear 

foreach year of numlist 1991/2016 {
    append using co2-emissions-country-industry_`year'.dta
}

order countryXindustry country country_code industry year grossoutput co2_scope1 co2_scope2 co2_rates_scope1 co2_rates_scope2

sort country country_code year industry

* save data 
save "${output}\data-stata\eora\03-co2-emissions-scope-2-country-industry"