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

	if (periodo == 2000 | periodo == 2001 | periodo == 2002 | periodo == 2003){
	
		* keep relevant variables 
		keep nordemp nordest dpto periodo /// id variables
		c5r1c1 c5r1c2 c5r1c3 c5r1c4 c3r19c3 totalv eelec /// energy variables
		c3r30c3 c3r35c3 /// cost variables
		prodbr2
	
		* rename basic variables
		rename nordemp id_firm

		* rename energy variables
		rename c5r1c1 energy_purchased_kwh
		rename c5r1c2 energy_generated_kwh
		rename c5r1c3 energy_sold_kwh
		rename c5r1c4 energy_consumed_kwh
		rename c3r19c3 cost_energy

		* rename gross output variable
		rename prodbr2 gross_output

		* create cost_energy_rate
		gen total_cost = c3r35c3 + c3r30c3
		gen energy_rate_total_cost = energy_consumed_kwh/total_cost
		gen energy_rate_gross_output = energy_consumed_kwh/gross_output
		
	}
	
	if (periodo == 2004 | periodo == 2005 | periodo == 2006){
		
		* keep relevant variables
		keep nordemp nordest dpto periodo /// id variables
		c5r1c1 c5r1c2 c5r1c3 c5r1c4 c3r19c3 totalv eelec /// energy variables
		c3r10c3 c3r14c3 c3r41c3 c3r42c3 c3r27c3 c3r35c1 c3r35c3 c7c7r4 /// cost variables
		prodbr2 /// gross output
		
		* rename basic variables
		rename nordemp id_firm
		
		* rename energy variables
		rename c5r1c1 energy_purchased_kwh
		rename c5r1c2 energy_generated_kwh
		rename c5r1c3 energy_sold_kwh
		rename c5r1c4 energy_consumed_kwh
		rename c3r19c3 cost_energy
		
		* rename gross output variable
		rename prodbr2 gross_output
		
		* create cost_energy_rate
		gen total_cost = c3r10c3 + c3r14c3 + c3r41c3 + c3r42c3 + c3r27c3 + c3r35c1 + c3r35c3 + c7c7r4
		gen energy_rate_total_cost = energy_consumed_kwh/total_cost
		gen energy_rate_gross_output = energy_consumed_kwh/gross_output
	}
	
	if (periodo == 2007){
		
		* keep relevant variables
		keep nordemp nordest dpto periodo /// id variables
		c5r1c1 c5r1c2 c5r1c3 c5r1c4 c3r19c3 totalv eelec /// energy variables
		c3r10c3 c3r44c3 c3r40c3 c3r14c3 c3r41c3 c3r42c3 c3r27c3 c3r35c1 c3r35c3 c3r45c3 c7c7r4 /// cost variables
		prodbr2 /// gross output
		
		* rename basic variables
		rename nordemp id_firm
	
		* rename energy variables
		rename c5r1c1 energy_purchased_kwh
		rename c5r1c2 energy_generated_kwh
		rename c5r1c3 energy_sold_kwh
		rename c5r1c4 energy_consumed_kwh
		rename c3r19c3 cost_energy
		
		* rename gross output variable
		rename prodbr2 gross_output
		
		* create cost_energy_rate
		gen total_cost = c3r10c3 + c3r44c3 + c3r40c3 + c3r14c3 + c3r41c3 + c3r42c3 + c3r27c3 + c3r35c1 + c3r35c3 + c3r45c3 + c7c7r4
		gen energy_rate_total_cost = energy_consumed_kwh/total_cost
		gen energy_rate_gross_output = energy_consumed_kwh/gross_output
	
	}
	
	if (periodo == 2008 | periodo == 2009 | periodo == 2010 | periodo == 2011 | periodo == 2012 | periodo == 2013 |periodo == 2014 | periodo == 2015 | periodo == 2016 | periodo == 2017 | periodo == 2018 | periodo == 2019){
		
		* keep relevant variables
		keep nordemp nordest dpto periodo /// id variables
		c5r1c1 c5r1c2 c5r1c3 c5r1c4 c3r19c3 totalv eelec /// energy variables
		c3r10c3 c3r14c3 c3r41c3 c3r45c3 c3r42c3 c3r27c3 c3r35c1 c3r35c3 c7c7r4 /// cost variables
		prodbr2 /// gross output
		
		* rename basic variables
		rename nordemp id_firm
		
		* rename energy variables
		rename c5r1c1 energy_purchased_kwh
		rename c5r1c2 energy_generated_kwh
		rename c5r1c3 energy_sold_kwh
		rename c5r1c4 energy_consumed_kwh
		rename c3r19c3 cost_energy
		
		* rename gross output variable
		rename prodbr2 gross_output
		
		* create cost_energy_rate
		gen total_cost = c3r10c3 + c3r14c3 + c3r41c3 + c3r45c3 + c3r42c3 + c3r27c3 + c3r35c1 + c3r35c3 + c7c7r4
		gen energy_rate_total_cost = energy_consumed_kwh/total_cost
		gen energy_rate_gross_output = energy_consumed_kwh/gross_output
	}
	
	
	* save data
	save "${dir_temp}/eam-energy/energy-data_`year'.dta", replace

}

* Finally we append data
cd "${dir_temp}/eam-energy"
use energy-data_2000.dta, clear 

foreach year of numlist 2001/2019 {
    append using energy-data_`year'.dta
}

* Drop those cost variables we do not need (just keep total cost)
drop c3r*
drop c7c7r4

* some handfull changes
rename periodo year

* We save data
save "${output}/data-stata/eam/01-energy-data.dta"