/*
********************************************************
THIS CODE CREATE A DATA SET WITH GROSS OUTPUT BY COUNTRY
********************************************************
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


*==============================================================================*
*                          Gross output by country and industry                *
*==============================================================================*

local start_year = 1990
local end_year = 2016

* Load and save countryXindustry once only
insheet using "${dir_source}\EORA\Eora26_1990_bp\labels_T.txt", tab clear
gen countryXindustry = _n
tostring countryXindustry, replace
save "${dir_temp}\countryXindustry.dta", replace

* Start timer to check loop duration
timer clear 1
timer on 1

foreach year of numlist `start_year'/`end_year' {
    * Load, transform, and save intermediates
    insheet using "${dir_source}\EORA\Eora26_`year'_bp\Eora26_`year'_bp_T.txt", tab clear
    collapse (sum) v1-v4915, fast
    gen one = 1
    reshape long v, i(one) j(countryXindustry)
    rename v intermediates
    drop one
	tostring countryXindustry, replace 
    tempfile intermediates_year
    save "`intermediates_year'", replace

    * Load, transform, and save valueadded
    insheet using "${dir_source}\EORA\Eora26_`year'_bp\Eora26_`year'_bp_VA.txt", tab clear
    collapse (sum) v1-v4915, fast
    gen one = 1
    reshape long v, i(one) j(countryXindustry)
    rename v valueadded
    drop one
	tostring countryXindustry, replace
    merge 1:1 countryXindustry using "`intermediates_year'", assert(3) nogen

    * Calculate grossoutput and save
    gen grossoutput = valueadded + intermediates
    merge 1:1 countryXindustry using "${dir_temp}\countryXindustry.dta", assert(3) nogen
    drop v5
    gen year = `year'
    save "${dir_temp}/gross-output/grossoutput_temp`year'.dta", replace
	
}


* Stop timer and display duration
timer off 1
timer list 1


* Finally we append data
cd "${dir_temp}/gross-output"
use grossoutput_temp1990.dta, clear 

foreach year of numlist 1991/2016 {
    append using grossoutput_temp`year'.dta
}

* Improve format
drop v3 valueadded intermediates
rename v1 country
rename v4 industry
rename v2 country_code
order countryXindustry country country_code industry year grossoutput
sort country country_code year industry
tostring year, replace

* add deflator and exchange rate data
merge m:1 country_code year using "${output}/data-stata/world bank/02-gdp_deflator.dta"

keep if _merge == 3
drop _merge

merge m:m country_code year using "${output}/data-stata/imf/01-exchange-rate.dta"

keep if _merge == 3
drop _merge

sort country industry year

* generate grossoutput variable in currente and local currency
gen grossoutput_local_current = (grossoutput*exchange_rate*gdp_deflator_adj)

* keep just essential variables
keep countryXindustry country country_code industry year grossoutput_local_current

* change format to match later
destring year, replace

* We save data
save "${output}/data-stata/eora/06-gross_output_country-industry_v2.dta", replace
