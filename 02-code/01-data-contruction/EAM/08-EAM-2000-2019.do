***** CODE EAM DATA *****

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
global dir_output "${dir_base}\04-output"


*===================================================================*
*                   merge all data from EAM                         *               
*===================================================================*

use "${dir_output}\data-stata\eam\01-income-data.dta", clear

* merge all data from eam
merge 1:1 id_firm nordest year using "${dir_output}\data-stata\eam\02-cost-data.dta", nogen
merge 1:1 id_firm nordest year using "${dir_output}\data-stata\eam\03-gross-output-data.dta", nogen
*merge 1:1 id_firm nordest year using "${dir_output}\data-stata\eam\04-export-import-data.dta", nogen
merge 1:1 id_firm nordest year using "${dir_output}\data-stata\eam\05-investment-data.dta", nogen
merge 1:1 id_firm nordest year using "${dir_output}\data-stata\eam\06-wages-data.dta", nogen
merge 1:1 id_firm nordest year using "${dir_output}\data-stata\eam\07-energy-data.dta", nogen

* merge macro data (did not merge those year < 2000)
merge m:1 year using "${dir_output}\data-stata\macro-indicators\01-exchange_rate_col_usd.dta", nogen
merge m:1 year using "${dir_output}\data-stata\macro-indicators\02-inflation_annual_usa.dta", nogen
merge m:1 year using "${dir_output}\data-stata\macro-indicators\03-inflation_annual_col.dta", nogen

keep if (year >= 2000) & (year <= 2019)

* some labels for variables macro
label variable exchange_rate_col_usd "Colombian peso per American dollar by year (mean)"
label variable inflation_rate_usa "Inflation rate for USA by year (mean)"
label variable inflation_rate_col "Inflation rate for Colombia by year (mean)"


gen oil_energy = petroc + diesc + fuelc + gasolc + kerosc
gen carbon_energy = carbonmc + carboncc + carbonvc 


* We save data
save "${output}/data-stata/eam/08-EAM-2000-2019.dta", replace

