/*
***************************************************************
***************************************************************
THIS CODE CREATE A DATA SET WITH CO2 RATES BY COUNTRY-INDUSTRY
***************************************************************
***************************************************************
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
use "${dir_output}\data-stata\eora\01-gross_output_country-industry.dta", clear
merge 1:1 country country_code industry year using "${dir_output}\data-stata\eora\03-co2-emissions-country-industry.dta", assert(3) nogen

sort country year industry


*======================*
*** Create co2 rates ***
*======================*

* first we note that some values for gross output are negative. We replace them for cero values
replace grossoutput = 0 if grossoutput < 0

* generate co2 emissions (scope 1) by gross output
gen co2_rate_scope_1 = grossoutput/co2A_SCOPE_1

* generate co2 emissions (scope 2) by gross output
gen co2_rate_scope_2 = grossoutput/co2A_SCOPE_2

* drop emissions B for now
drop co2B_SCOPE_1 co2B_SCOPE_2

* save data
save "${dir_output}\data-stata\eora\04-co2_rates_country-industry.dta"