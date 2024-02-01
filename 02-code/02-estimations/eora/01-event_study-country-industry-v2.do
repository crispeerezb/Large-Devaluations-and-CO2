/*
*****************************
*****************************
THIS CODE ESTIMATE EVENT STUDY
******************************
******************************
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

/*
scc install eventdd, replace
ssc install matsort, replace
*/

*** set path where i store the data ***
global wd "${dir_base}\01-code"
global dir_temp "${dir_base}\03-temp"
global dir_source "C:\Users\crist\Dropbox Dropbox\Cristóbal Pérez Barraza\A-Large Devaluations and CO2\DataRaw" // note this one is not in the repository
global output "${dir_base}\04-output"


*** load data set ***
use "${output}\data-stata\eora\04-electricity-spending.dta", clear


*** We collapse data to have data country-year level
collapse (sum) energy_spending grossoutput, by(country country_code year)

*** Generate grossoutput variable lagged
sort country year

** Add data from penn table ***
merge 1:1 country_code year using "${dir_base}\01-raw-data\penn_world_tables\pwt100_temp.dta", keep(3) nogen
keep country country_code year energy_spending grossoutput lrgdpo

* Generate event for large devaluations
gen Event=0
replace Event=2002 if country_code=="ARG"
replace Event=1995 if country_code=="MEX"
replace Event=1998 if country_code=="RUS"
replace Event=1993 if country_code=="FIN"
replace Event=2008 if country_code=="ISL"
replace Event=1997 if country_code=="MYS"
replace Event=1998 if country_code=="IDN"
replace Event=1998 if country_code=="THA"
replace Event=1998 if country_code=="KOR"
replace Event=1994 if country_code=="TUR" 
replace Event=2001 if country_code=="TUR" 
replace Event=1999 if country_code=="BRA" 
replace Event=1991 if country_code=="IND" 
replace Event=2014 if country_code=="COL" 

* Drop other countries 
drop if Event==0

* Outcome variable
gen cost_energy_share = energy_spending/grossoutput
gen ln_cost_energy_share = ln(cost_energy_share)

* Time to Treat variable
gen TimeToTreat= year - Event
encode country, generate(country_num)

* Regression
eventdd ln_cost_energy_share lrgdpo i.year i.country_num, timevar(TimeToTreat) ci(rcap) ///
cluster(country_num) graph_op(ytitle("Log Energy Cost Share") xlabel(-20(5)25))