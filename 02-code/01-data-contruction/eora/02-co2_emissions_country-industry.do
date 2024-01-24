/*
******************************************************************
******************************************************************
THIS CODE CREATE A DATA SET WITH CO2 EMISSIONS BY COUNTRY-INDUSTRY
******************************************************************
******************************************************************
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

local start_year = 1990
local end_year = 1999

foreach year of numlist `start_year'/`end_year' {

	insheet using "${dir_source}\EORA\Eora26_`year'_bp\Eora26_`year'_bp_Q.txt",  tab clear
	* eora has two groups of co2 variables, called "co2" and "co2b". not sure what
	* the 'b' variables are, but calculate both/separately here.
	g       type = "A" in 10/64
	replace type = "B" in 65/119
	replace type = "A_SCOPE_1" in 10/64
	replace type = "A_SCOPE_2" in 10/11 // Public electricity and heat production - Other Energy Industries
	replace type = "B_SCOPE_1" in 65/119
	replace type = "B_SCOPE_2" in 65/66 // Public electricity and heat production - Other Energy Industries

	drop if type == ""

	collapse (sum) v*, by(type) fast
	reshape long v, i(type) j(countryXindustry)
	rename v co2
	reshape wide co2, i(countryXindustry) j(type) string

	tostring countryXindustry, replace
	merge 1:1 countryXindustry using "${dir_temp}\countryXindustry.dta", assert(3) nogen
	drop v5

	replace co2A_SCOPE_1 = 1000*co2A_SCOPE_1
	replace co2A_SCOPE_2 = 1000*co2A_SCOPE_2
	replace co2B_SCOPE_1 = 1000*co2B_SCOPE_1
	replace co2B_SCOPE_2 = 1000*co2B_SCOPE_2
	
	gen year = `year'
	
	save "${dir_temp}/co2-emissions/co2-emissions-country-industry_`year'.dta", replace

}

* Finally we append data
cd "${dir_temp}/co2-emissions"
use co2-emissions-country-industry_1990.dta, clear 

foreach year of numlist 1991/2016 {
    append using co2-emissions-country-industry_`year'.dta
}

* Improve format
drop v3
rename v1 country
rename v4 industry
rename v2 country_code
order countryXindustry country country_code industry year co2*
sort country country_code year industry

* We save data
save "${output}/data-stata/eora/03-co2-emissions-country-industry.dta"