/*--------------------------------------------------------------------------------*/
/*-------Shift-Share: Evidence for Negative Shocks on Firms' Emissions------------*/
/*--------------------------------------------------------------------------------*/


* ========================= *
* ====== Set up code ====== *
* ========================= *


* set working dictory
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


* set path where i store the data
global wd "${dir_base}\01-code"
global dir_temp "${dir_base}\03-temp"
global dir_source "C:\Users\crist\Dropbox Dropbox\Cristóbal Pérez Barraza\A-Large Devaluations and CO2\DataRaw" // note this one is not in the repository
global output "${dir_base}\04-output"
global results "${dir_base}\05-results\eam\regressions"


/*-------------------------------------------------------*/
/*-----------------------PRELIMINARIES-------------------*/
/*-------------------------------------------------------*/

* load data set
use "${output}\data-stata\eam\09-EAM-2012-2019-Shift-Share", clear

* set global for program
global outcome1="co2_intensity"
global outcome2="co2_emission"
global outcome3="energy_purchased_kwh"
global outcome4="energy_generated_kwh"
global outcome5= "labor"
global outcome6="invebrta"
global outcome7="cost_energy"
global timevar="year" 
global productvar="id_firm_code"
global controls1="gross_output labor invebrta" /*If want to add controls*/
global controls2="valorven labor invebrta"

* set a code for firms
encode id_firm, gen(id_firm_code)

* gen co2 emission in kg
gen co2_emission = co2_emission_ton*1000

* add labels
label variable id_firm "Firm ID"
label variable year "Year"
label variable co2_emission_ton "CO2 Emissions (Tons)"
label variable co2_emission "CO2 Emissions (Kg)"
label variable carbon_emission "CO2 Emissions from Carbon (Tons)"
label variable fuel_emission "CO2 Emissions from Fuel (Tons)"
label variable gas_emission "CO2 Emissions from Gas (Tons)"
label variable gross_output "Gross Output (Pesos)"
label variable valorven "Sales (Pesos)"
label variable total_cost "Total Cost (Pesos)"
label variable cost_energy "Cost Energy (Pesos)"
label variable energy_purchased_kwh "Energy Purchased (kWh)"
label variable industrial_output "Gross Output (Industrial)"
label variable invebrta "Gross Investment (Pesos)"


* rename employment variable by labor (it is more occurate)
rename employment labor
label variable labor "Workforce"

/*----------------------------------------------------*/
/*-----------------------ESTIMATION-------------------*/
/*----------------------------------------------------*/

* ====================================================== *
* 1.- Let's see what happend with energies and emissions *
* ====================================================== *

eststo drop *

* co2_intensity
*xi: reghdfe $outcome1 shift_share_Z_it $controls2, a($timevar $productvar) cluster($productvar)

* co2_emission (kg)
eststo m11: reghdfe $outcome2 shift_share_Z_it $controls1, a($timevar $productvar) cluster($productvar)

* energy_purchased_kwh
eststo m12: reghdfe $outcome3 shift_share_Z_it $controls1, a($timevar $productvar) cluster($productvar)

* energy_generated_kwh
eststo m13: reghdfe $outcome4 shift_share_Z_it $controls1, a($timevar $productvar) cluster($productvar)

* energy cost
eststo m14: reghdfe $outcome7 shift_share_Z_it $controls1, a($timevar $productvar) cluster($productvar)

* save table
esttab m11 m12 m13 m14 using "${results}\energy_and_emissions.tex", b(3) r2(3) ar2(3) se(3) depvars label compress star(* 0.10 ** 0.05 *** 0.01) replace

* ================================================= *
* 2.- Let's see what happend with production factor *
* ================================================= *

eststo drop *

* labor
eststo m21: reghdfe $outcome5 shift_share_Z_it gross_output, a($timevar $productvar) cluster($productvar)

* invebrta 
eststo m22: reghdfe $outcome6 shift_share_Z_it gross_output, a($timevar $productvar) cluster($productvar)

* save table
esttab m21 m22 using "${results}\factors.tex", b(3) r2(3) ar2(3) se(3) depvars label compress star(* 0.10 ** 0.05 *** 0.01) replace


