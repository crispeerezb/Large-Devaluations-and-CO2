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

foreach year of numlist 1991/2009 {
    append using grossoutput_temp`year'.dta
}

* Improve format: rename variables and drop those that we don't need anymore
drop v3 valueadded intermediates
rename v1 country
rename v4 industry
rename v2 country_code
order countryXindustry country country_code industry year grossoutput
sort country country_code year industry
drop if country == "Statistical Discrepancies"

* add deflator and exchange rate data
merge m:1 country_code year using "${output}/data-stata/world bank/02-gdp_deflator.dta"

* we drop those countries that are not in master data set
drop if _merge == 1
drop if _merge == 2
drop _merge

* add exchange rate data set
merge m:1 country_code year using "${dir_base}\01-raw-data\penn_world_tables\pwt100_temp.dta", keep(3) nogen

keep countryXindustry country country_code industry year grossoutput gdp_deflator xr

* drop those countries with missing data
drop if missing(gdp_deflator) | missing(grossoutput) | missing(xr)

sort country industry year

* generate grossoutput variable in currente and local currency
gen grossoutput_LC = ((grossoutput*xr)/gdp_deflator)*100

* finally we add ppp rates and create gross output ppps
merge m:1 country country_code year using "${output}\data-stata\imf\02-ppp-rate.dta"
drop if _merge != 3
drop _merge

gen grossoutput_PPP = grossoutput_LC/ppp_rate

* keep just essential variables
keep countryXindustry country country_code industry year grossoutput_LC grossoutput_PPP grossoutput

* now we add emissions variables
merge m:m countryXindustry country country_code using "${output}\data-stata\eora\03-co2-emissions-scope-2-country-industry.dta"

drop if _merge == 2
drop _merge

* add labels
label variable countryXindustry "Code for the country industry combination"
label variable country "Country"
label variable country_code "three digit code for country"
label variable industry "Industrial sector"
label variable year "Period"
label variable grossoutput "Gross output in Dollars"
label variable grossoutput_PPP "Gross output in Dollars adjusted by PPPs"
label variable grossoutput_LC "Gross output in Constant Local Currency"
label variable co2_scope1 "CO2 emissions from scope 1"
label variable co2_scope2 "CO2 emissions from scope 2"

* We save data
save "${output}/data-stata/eora/06-EORA-COUNTRY-INDUSTRY-1990-2009_V2.dta", replace
