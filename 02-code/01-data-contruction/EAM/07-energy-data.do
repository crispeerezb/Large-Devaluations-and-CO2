***** CODE FOR ENERGY DATA FROM EAM *****

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


*===================================================================*
*                          Energy data by firm level                *
*===================================================================*

/*
energy variable in 2018:
c5r1c1
c5r1c2 
c5r1c3
c5r1c4
c5r1c5 --> does not exist in 2000
c5r1c7 --> does not exist in 2000
c3r19c3
TOTALV 
EELEC
*/


/*
cost variables: the next two have all costs included
C3R30C3 
C3R35C3
*/


/*
gross output variable: prodbr2
*/

local start_year = 2000
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
	c5r1c1 c5r1c2 c5r1c3 c5r1c4 c3r19c3 totalv eelec /// energy variables
	petroc diesc fuelc gasolc kerosc /// oil (quantity) NOTE: all in tons
	gasnc gaspc /// gas (quantity) NOTE: Natural Gas mt3 and Propone Libra
	carbonmc carboncc carbonvc /// carbon (quantity) NOTE: all in tons
	petrov diesv fuelv gasolv kerosv /// oil (value)
	gasnv gaspv /// gas (value)
	carbonmv carboncv carbonvv /// carbon (value)
	
	* rename basic variables
	rename nordemp id_firm

	* rename energy variables
	rename c5r1c1 energy_purchased_kwh
	rename c5r1c2 energy_generated_kwh
	rename c5r1c3 energy_sold_kwh
	rename c5r1c4 energy_consumed_kwh
	rename c3r19c3 cost_energy
	
	* save data
	save "${dir_temp}/eam-energy/energy-data_`year'.dta", replace

}

* Finally we append data
cd "${dir_temp}/eam-energy"
use energy-data_2000.dta, clear 

foreach year of numlist 2001/2019 {
    append using energy-data_`year'.dta
}

* some handfull changes
rename periodo year

* gen ciiu to have all of them in one variables
gen ciiu_final = .
replace ciiu_final = ciiu2 if missing(ciiu_final) & !missing(ciiu2)
replace ciiu_final = ciiu if missing(ciiu_final) & !missing(ciiu)
replace ciiu_final = ciiu3 if missing(ciiu_final) & !missing(ciiu3)
replace ciiu_final = ciiu4 if missing(ciiu_final) & !missing(ciiu4)
replace ciiu_final = ciiu_4 if missing(ciiu_final) & !missing(ciiu_4)

drop ciiu ciiu3 ciiu4 ciiu_4 ciiu2

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
save "${output}/data-stata/eam/07-energy-data.dta", replace
