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


/************
Observations:
*************

1) Note that the data used here isn't in the GitHub repository since this data is too big

*/



insheet using "${dir_source}\EORA\Eora26_2010_bp\Eora26_2010_bp_Q.txt",  tab clear
* eora has two groups of co2 variables, called "co2" and "co2b". not sure what
* the 'b' variables are, but calculate both/separately here.
g       type = "A" in 10/64
replace type = "B" in 65/119
drop if type == ""

collapse (sum) v*, by(type) fast
reshape long v, i(type) j(countryXindustry)
ren v co2
reshape wide co2, i(countryXindustry) j(type) string

tostring countryXindustry, replace
merge 1:1 countryXindustry using "${dir_temp}\countryXindustry.dta", assert(3) nogen

gen co2rate_scope1_eora = 1000*co2A