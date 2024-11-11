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

* set a code for firms
encode id_firm, gen(id_firm_code)

* gen co2 emission in kg
*gen co2_emission = co2_emission_ton*1000

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

* gen variables in log
gen ln_co2_emission = log(co2_emission+1)
gen ln_energy_purchased_kwh = log(energy_purchased_kwh+1)
gen ln_energy_generated_kwh = log(energy_generated_kwh+1)
gen ln_labor = log(labor+1)
*gen ln_invebrta = log(invebrta+1)
gen ln_cost_energy = log(cost_energy+1)
gen ln_energy_consumed_kwh = log(energy_consumed_kwh+1)
gen ln_energy_sold_kwh = log(energy_sold_kwh+1)
gen ln_gross_output = log(gross_output+1)
gen ln_valorven = log(valorven+1)
gen ln_import = log(valorcx+1)
gen ln_total_cost = log(total_cost+1)

* outcomes in levels
global outcome1="co2_intensity"
global outcome2="co2_emission"
global outcome3="energy_purchased_kwh"
global outcome4="energy_generated_kwh"
global outcome5= "labor"
global outcome6="invebrta"
global outcome7="cost_energy"
global outcome8="energy_consumed_kwh"
global outcome9="energy_sold_kwh"

* outcomes in log and diff
global ln_outcome_diff_1="ln_co2_intensity_diff"
global ln_outcome_diff_2="ln_co2_emission_diff"
global ln_outcome_diff_3="ln_energy_purchased_kwh_diff"
global ln_outcome_diff_4="ln_energy_generated_kwh_diff"
global ln_outcome_diff_5="ln_energy_consumed_kwh_diff"
global ln_outcome_diff_6="ln_energy_sold_kwh_diff"

* outcomes in log
global ln_outcome1="ln_co2_intensity"
global ln_outcome2="ln_co2_emission"
global ln_outcome3="ln_energy_purchased_kwh"
global ln_outcome4="ln_energy_generated_kwh"
global ln_outcome5="ln_energy_consumed_kwh"
global ln_outcome6="ln_energy_sold_kwh"


* fixed effects
global timevar="year" 
global productvar="id_firm_code"

* controls
global controls1="ln_labour_diff"
global controls2="ln_labour_diff ln_invebrta_diff"
global controls3="ln_labour_diff ln_invebrta_diff ln_total_cost_diff"
global controls4="ln_labour_diff ln_invebrta_diff ln_cost_energy_diff"

/*------------------------------------------------------------------------------------*/
/*---------------------ESTIMATION USING GROSS OUTPUT FOR SHIFT-SHARE------------------*/
/*------------------------------------------------------------------------------------*/

* ====================================================== *
* 1.- Let's see what happend with energies and emissions *
* ====================================================== *

*****************************************************
* NOTE: here all dep. variables are in log and diff *
*****************************************************

*\---- ln_co2_intensity ----\*

* OLS
eststo drop *

eststo: reghdfe $ln_outcome_diff_1 ln_gross_output_diff, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_1 ln_gross_output_diff $controls1, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_1 ln_gross_output_diff $controls2, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_1 ln_gross_output_diff $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\CO2-Intensity-OLS.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace


* IV
eststo drop *

eststo: ivreghdfe $ln_outcome_diff_1 (ln_gross_output_diff = shift_share_S_it), a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_1 (ln_gross_output_diff = shift_share_S_it) $controls1, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_1 (ln_gross_output_diff = shift_share_S_it) $controls2, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_1 (ln_gross_output_diff = shift_share_S_it) $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\CO2-Intensity-IV.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace

*\---- ln_co2_emission (kg) ----\*

* OLS
eststo drop *

eststo: reghdfe $ln_outcome_diff_2 ln_gross_output_diff, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_2 ln_gross_output_diff $controls1, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_2 ln_gross_output_diff $controls2, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_2 ln_gross_output_diff $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\CO2-Emissions-OLS.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace

* IV
eststo drop *

eststo: ivreghdfe $ln_outcome_diff_2 (ln_gross_output_diff = shift_share_S_it), a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_2 (ln_gross_output_diff = shift_share_S_it) $controls1, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_2 (ln_gross_output_diff = shift_share_S_it) $controls2, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_2 (ln_gross_output_diff = shift_share_S_it) $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\CO2-Emissions-IV.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace


*\---- ln_energy_purchased_kwh ----\*

* OLS
eststo drop *

eststo: reghdfe $ln_outcome_diff_3 ln_gross_output_diff, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_3 ln_gross_output_diff $controls1, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_3 ln_gross_output_diff $controls2, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_3 ln_gross_output_diff $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\Energy-Purchased-OLS.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace

* IV
eststo drop *

eststo: ivreghdfe $ln_outcome_diff_3 (ln_gross_output_diff = shift_share_S_it), a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_3 (ln_gross_output_diff = shift_share_S_it) $controls1, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_3 (ln_gross_output_diff = shift_share_S_it) $controls2, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_3 (ln_gross_output_diff = shift_share_S_it) $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\Energy-Purchased-IV.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace


*\---- ln_energy_generated_kwh ----\*

* OLS
eststo drop *

eststo: reghdfe $ln_outcome_diff_4 ln_gross_output_diff, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_4 ln_gross_output_diff $controls1, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_4 ln_gross_output_diff $controls2, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_4 ln_gross_output_diff $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\Energy-Generated-OLS.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace

* IV
eststo drop *

eststo: ivreghdfe $ln_outcome_diff_4 (ln_gross_output_diff = shift_share_S_it), a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_4 (ln_gross_output_diff = shift_share_S_it) $controls1, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_4 (ln_gross_output_diff = shift_share_S_it) $controls2, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_4 (ln_gross_output_diff = shift_share_S_it) $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\Energy-Generated-IV.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace


*\---- ln_energy_consumed_kwh ----\*

* OLS
eststo drop *

eststo: reghdfe $ln_outcome_diff_5 ln_gross_output_diff, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_5 ln_gross_output_diff $controls1, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_5 ln_gross_output_diff $controls2, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_5 ln_gross_output_diff $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\Energy-Consumed-OLS.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace

* IV
eststo drop *

eststo: ivreghdfe $ln_outcome_diff_5 (ln_gross_output_diff = shift_share_S_it), a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_5 (ln_gross_output_diff = shift_share_S_it) $controls1, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_5 (ln_gross_output_diff = shift_share_S_it) $controls2, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_5 (ln_gross_output_diff = shift_share_S_it) $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\Energy-Consumed-IV.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace


*\---- ln_energy_sold_kwh ----\*

* OLS
eststo drop *

eststo: reghdfe $ln_outcome_diff_6 ln_gross_output_diff, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_6 ln_gross_output_diff $controls1, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_6 ln_gross_output_diff $controls2, a($timevar $productvar) cluster($productvar)

eststo: reghdfe $ln_outcome_diff_6 ln_gross_output_diff $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\Energy-Sold-OLS.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace

* IV
eststo drop *

eststo: ivreghdfe $ln_outcome_diff_6 (ln_gross_output_diff = shift_share_S_it), a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_6 (ln_gross_output_diff = shift_share_S_it) $controls1, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_6 (ln_gross_output_diff = shift_share_S_it) $controls2, a($timevar $productvar) cluster($productvar)

eststo: ivreghdfe $ln_outcome_diff_6 (ln_gross_output_diff = shift_share_S_it) $controls3, a($timevar $productvar) cluster($productvar)

esttab using "${results}\Energy-Sold-IV.tex", b(3) se(3) compress nodepvars nomtitles label star(* 0.10 ** 0.05 *** 0.01) replace

