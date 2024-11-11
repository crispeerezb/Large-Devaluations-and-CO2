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
merge 1:1 id_firm nordest year using "${dir_output}\data-stata\eam\04-export-import-data.dta", nogen
merge 1:1 id_firm nordest year using "${dir_output}\data-stata\eam\05-investment-data.dta", nogen
merge 1:1 id_firm nordest year using "${dir_output}\data-stata\eam\06-wages-data.dta", nogen
merge 1:1 id_firm nordest year using "${dir_output}\data-stata\eam\07-energy-data.dta", nogen

* merge macro data (did not merge those year < 2000)
merge m:1 year using "${dir_output}\data-stata\macro-indicators\01-exchange_rate_col_usd.dta", nogen
merge m:1 year using "${dir_output}\data-stata\macro-indicators\02-inflation_annual_usa.dta", nogen
merge m:1 year using "${dir_output}\data-stata\macro-indicators\03-inflation_annual_col.dta", nogen

keep if (year >= 2005) & (year <= 2019)

* generate emissions variables according with emissions factors

* 1) carbon (in tons)
local factor_carbon_coque 3.140
local factor_carbon_mineral 2.460
local factor_carbon_vegetal 3.670

gen emission_carbonmc = (carbonmc*`factor_carbon_mineral')
gen emission_carboncc = (carboncc*`factor_carbon_coque')
gen emission_carbonvc = (carbonvc*`factor_carbon_vegetal')

gen carbon_emission = emission_carbonmc + emission_carboncc + emission_carbonvc

* 2) fuel (in galon)
local factor_petrol 10.35
local factor_diesel 10.21
local factor_fuel 11.27
local factor_gasol 8.78
local factor_kero 9.75

gen emission_diesc = (diesc*`factor_diesel')/1000
gen emission_fuelc = (fuelc*`factor_fuel')/1000
gen emission_gasolc = (gasolc*`factor_gasol')/1000
gen emission_kerosc = (kerosc*`factor_kero')/1000
gen emission_petroc = (petroc*`factor_petrol')/1000

gen fuel_emission = emission_diesc + emission_fuelc + emission_gasolc + emission_kerosc + emission_petroc

* 3) gas (in cubic meter and pound)
local factor_gas_natural 1.93
local factor_gas_propano 1.54

gen emission_gas_natural = (gasnc*`factor_gas_natural')/1000
gen emission_gas_propano = (gaspc*`factor_gas_propano')/1000

gen gas_emission = emission_gas_natural + emission_gas_propano

* 4) total emissions
gen co2_emission_ton = carbon_emission + fuel_emission + gas_emission

*collapse (sum) gas_emission

*gen porc_carbon = carbon_emission/co2_emission_ton
*gen porc_fuels = fuel_emission/co2_emission_ton
*gen porc_gas = gas_emission/co2_emission_ton


* data by firm and year
*collapse (sum) totalv co2_emission_ton carbon_emission fuel_emission gas_emission gross_output valorven total_cost cost_energy energy_purchased_kwh industrial_output invebrta employment salpeyte valorcx porcvt (max) ciiu exchange_rate_col_usd inflation_rate_usa inflation_rate_col, by(id_firm ciiu year)

* keep only 2010 or more
keep if year >= 2005

* add labels
label variable exchange_rate_col_usd "Colombian peso per American dollar by year (mean)"
label variable inflation_rate_usa "Inflation rate for USA by year (mean)"
label variable inflation_rate_col "Inflation rate for Colombia by year (mean)"
label variable id_firm "Firm ID"
label variable year "Year"
label variable co2_emission_ton "CO2 Emissions (Tons)"
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
label variable salpeyte "Total Salary"
label variable valorcx "Imports (Pesos)"
label variable porcvt "Exports (Pesos)"
label variable ciiu "Industry"

* We save data
save "${dir_output}/data-stata/eam/10-EAM-2005-2019.dta", replace
