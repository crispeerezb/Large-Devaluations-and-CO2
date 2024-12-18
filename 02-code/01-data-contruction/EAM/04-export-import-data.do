***** CODE FOR EXPORT AND IMPORT BY FIRM FROM EAM *****

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


*==========================================================================*
*                          export-import data by firm level                *
*==========================================================================*

/*
gross output variable: prodbr2
*/

local start_year = 2005
local end_year = 2019

foreach year of numlist `start_year'/`end_year' {
	display `year'
	use "${dir_source}\EAM\EAM_`year'.dta", replace
	
	foreach var of varlist _all {
		local newvar = lower("`var'")
		rename `var' `newvar'
	}
	
	* NOTE: unfortunately porcvt isn't in 2014
	if (periodo == 2014){
		
		* keep relevant variables 
		keep nordemp nordest dpto ciiu* periodo /// id variables
		valorcx
	
		* rename basic variables
		rename nordemp id_firm
	
		* save data
		save "${dir_temp}/eam-export-import/export-import-data_`year'.dta", replace
	}
	
	else{
		
		* keep relevant variables 
		keep nordemp nordest dpto ciiu* periodo /// id variables
		valorcx porcvt
	
		* rename basic variables
		rename nordemp id_firm
	
		* save data
		save "${dir_temp}/eam-export-import/export-import-data_`year'.dta", replace
		
	}

}

* Finally we append data
cd "${dir_temp}/eam-export-import"
use export-import-data_2005.dta, clear 

foreach year of numlist 2006/2019 {
    append using export-import-data_`year'.dta
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
save "${output}/data-stata/eam/04-export-import-data.dta", replace
