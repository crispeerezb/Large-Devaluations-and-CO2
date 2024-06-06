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

keep if (year >= 2000) & (year <= 2019)

* generate emissions variables according with emissions factors

* 1) carbon
local factor_carbon_coque 3.1
local factor_carbon_mineral 2.86
local factor_carbon_vegetal 1.84

gen emission_carbonmc = (carbonmc*`factor_carbon_mineral')/1000
gen emission_carboncc = (carboncc*`factor_carbon_coque')/1000
gen emission_carbonvc = (carbonvc*`factor_carbon_vegetal')/1000

gen carbon_emission = emission_carbonmc + emission_carboncc + emission_carbonvc

* 2) fuel
local factor_petrol 10.21
local factor_diesel 10.21
local factor_fuel 11.27
local factor_gasol 8.78
local factor_kero 9.75

gen emission_diesc = (diesc*`factor_diesel')/1000
gen emission_fuelc = (fuelc*`factor_fuel')/1000
gen emission_gasolc = (gasolc*`factor_gasol')/1000
gen emission_kerosc = (kerosc*`factor_kero')/1000
gen emission_petroc = (petroc*`factor_petrol')/1000

gen fossil_fuel_emission = emission_diesc + emission_fuelc + emission_gasolc + emission_kerosc + emission_petroc

* 3) gas
local factor_gas_natural 1.92
local factor_gas_propano 0.0215

gen emission_gas_natural = (gasnc*`factor_gas_natural')/1000
gen emission_gas_propano = (gaspc*`factor_gas_propano')/1000

gen gas_emission = emission_gas_natural + emission_gas_propano

* 4) total emissions
gen co2_emission_ton = emission_carbonmc + emission_carboncc + emission_carbonvc + emission_diesc + emission_fuelc + emission_gasolc + emission_kerosc + emission_petroc + emission_gas_natural + emission_gas_propano

* data by firm and year
collapse (sum) co2_emission_ton carbon_emission fossil_fuel_emission gas_emission gross_output valorven total_cost cost_energy industrial_output invebrta salpeyte valorcx porcvt (max) ciiu exchange_rate_col_usd inflation_rate_usa inflation_rate_col, by(id_firm year)

* keep only 2010 or more
keep if year >= 2010

* add labels
label variable exchange_rate_col_usd "Colombian peso per American dollar by year (mean)"
label variable inflation_rate_usa "Inflation rate for USA by year (mean)"
label variable inflation_rate_col "Inflation rate for Colombia by year (mean)"
label variable id_firm "Firm ID"
label variable year "Year"
label variable co2_emission_ton "CO2 Emissions in Tons"
label variable carbon_emission "CO2 Emissions from Carbon"
label variable fossil_fuel_emission "CO2 Emissions from Fuel"
label variable gas_emission "CO2 Emissions from Gas"
label variable gross_output "Gross Output"
label variable valorven "Sales"
label variable total_cost "Total Cost"
label variable cost_energy "Cost Energy"
label variable industrial_output "Gross Output (Industrial)"
label variable invebrta "Gross Investment"
label variable salpeyte "Total Salary"
label variable valorcx "Imports"
label variable porcvt "Exports"
label variable ciiu "Industry"

* We save data
save "${dir_output}/data-stata/eam/08-EAM-2000-2019.dta", replace

****************
*** temporal ***
****************

* only see last year
keep if year == 2019

* gen log variables to check correlation
gen ln_emission_rate_output = log(co2_emission_ton/gross_output)
gen ln_emission_rate_output_in = log(co2_emission_ton/industrial_output)
gen ln_emission_rate_sales = log(co2_emission_ton/valorven)
gen ln_cost_energy_rate = log(cost_energy/total_cost)

gen ln_emission_carbon_rate_output = log(carbon_emission/gross_output)
gen ln_emission_ffuels_rate_output = log(fossil_fuel_emission/gross_output)

gen ln_import = log(valorcx)
gen ln_export = log(porcvt)

*== imports and exports correlation ==*

* correlation log emission per gross_output 
pwcorr ln_emission_rate_output ln_import
pwcorr ln_emission_rate_output ln_export

reg ln_emission_rate_output ln_import ln_export
/*
             | ln_emi.. ln_imp~t
-------------+------------------
ln_emissio.. |   1.0000 
   ln_import |   0.0182   1.0000 


             | ln_emi.. ln_exp~t
-------------+------------------
ln_emissio.. |   1.0000 
   ln_export |   0.0931   1.0000 
   

------------------------------------------------------------------------------
ln_emissio.. | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   ln_import |  -.0931145   .0362891    -2.57   0.010    -.1643266   -.0219023
   ln_export |   .2277022   .0387724     5.87   0.000     .1516169    .3037876
       _cons |  -14.77987   .5601485   -26.39   0.000    -15.87909   -13.68066
------------------------------------------------------------------------------

* Interesting negative relation beewtween ln_import and ln_emissions. It means that import firms are cleaner and exports firm dirtier? Which meke sense if we found that large devalution make emission increase CO2 intensity, since those events are a positive shock for exporter and a negative shock for importers.
*/


* correlation log emission per industrial_output 
pwcorr ln_emission_rate_output_in ln_import
pwcorr ln_emission_rate_output_in ln_export

/*
             | ln_emi~n ln_imp~t
-------------+------------------
ln_emissio~n |   1.0000 
   ln_import |   0.0177   1.0000 



             | ln_emi~n ln_exp~t
-------------+------------------
ln_emissio~n |   1.0000 
   ln_export |   0.0933   1.0000 
*/



* correlation log fossil fuel emission per gross_output
pwcorr ln_emission_ffuels_rate_output ln_import
pwcorr ln_emission_ffuels_rate_output ln_export

reg ln_emission_ffuels_rate_output ln_import ln_export
/*
             | l~ffue~t ln_imp~t
-------------+------------------
l~ffuels_r~t |   1.0000 
   ln_import |  -0.2988   1.0000 


             | l~ffue~t ln_exp~t
-------------+------------------
l~ffuels_r~t |   1.0000 
   ln_export |  -0.3590   1.0000

 
------------------------------------------------------------------------------
l~ffuels_r~t | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   ln_import |  -.1197045   .0407066    -2.94   0.003    -.1996531   -.0397558
   ln_export |  -.2317155   .0432219    -5.36   0.000    -.3166041   -.1468268
       _cons |  -9.665758    .644377   -15.00   0.000    -10.93133   -8.400189
------------------------------------------------------------------------------
*/


