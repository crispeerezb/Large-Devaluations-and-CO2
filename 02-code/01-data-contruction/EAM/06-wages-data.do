***** CODE FOR WAGES BY FIRM FROM EAM *****

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
global wd "${dir_base}\02-code"
global dir_temp "${dir_base}\03-temp"
global output "${dir_base}\04-output"


*==================================================================*
*                          wages data by firm level                *
*==================================================================*

local start_year = 2010
local end_year = 2019

foreach year of numlist `start_year'/`end_year' {
	display `year'
	use "${dir_source}\EAM\EAM_`year'.dta", replace
	
	foreach var of varlist _all {
		local newvar = lower("`var'")
		rename `var' `newvar'
	}
	
	* keep relevant variables 
	keep nordemp nordest dpto ciiu* periodo /// id variables
	salpeyte /// wages
	c4r4c9t c4r4c10t /// employment
	
	* rename basic variables
	rename nordemp id_firm
	
	* save data
	save "${dir_temp}/eam-wages/wages-data_`year'.dta", replace

}

* Finally we append data
cd "${dir_temp}/eam-wages"
use wages-data_2010.dta, clear 

foreach year of numlist 2011/2019 {
    append using wages-data_`year'.dta
}


* some handfull changes
rename periodo year

* gen ciiu to have all of them in one variables
gen ciiu_final = .
*replace ciiu_final = ciiu2 if missing(ciiu_final) & !missing(ciiu2)
*replace ciiu_final = ciiu if missing(ciiu_final) & !missing(ciiu)
replace ciiu_final = ciiu3 if missing(ciiu_final) & !missing(ciiu3)
replace ciiu_final = ciiu4 if missing(ciiu_final) & !missing(ciiu4)
replace ciiu_final = ciiu_4 if missing(ciiu_final) & !missing(ciiu_4)

drop ciiu3 ciiu4 ciiu_4

rename ciiu_final ciiu

order id_firm nordest dpto ciiu year

* generate employment variable: note those are man and women employes
gen employment = c4r4c9t + c4r4c10t
drop c4r4c9t c4r4c10t

/* Finally, we extract only first two characters in ciiu
tostring ciiu, gen(ciiu_string)
gen ciiu_2 = substr(ciiu_string, 1, 2)

replace ciiu_2 = "1" if ciiu == 13
replace ciiu_2 = "1" if ciiu == 14
replace ciiu_2 = "2" if ciiu == 20 
replace ciiu_2 = "2" if ciiu == 22
replace ciiu_2 = "2" if ciiu == 24
replace ciiu_2 = "2" if ciiu == 26
replace ciiu_2 = "2" if ciiu == 27
replace ciiu_2 = "2" if ciiu == 28
replace ciiu_2 = "2" if ciiu == 29
replace ciiu_2 = "3" if ciiu == 31

merge m:1 ciiu_2 using "${output}/data-stata/eam/00-eam_ciiu.dta", nogenerate keep(1 3)
*/

* We save data
save "${output}/data-stata/eam/06-wages-data.dta", replace