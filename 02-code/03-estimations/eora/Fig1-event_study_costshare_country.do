/*
*****************************
*****************************
THIS CODE ESTIMATE EVENT STUDY
******************************
******************************
*/


*** set working dictory ***
clear
global usuario "ezequiel.garcia"
{
	if "$usuario" == "ezequiel.garcia" {
		global dir_base "C:\Users\ezequiel.garcia\Desktop\Projects\Large-Devaluations-and-CO2\"
	}
	if "$usuario" == "CP" {
		global dir_base "C:\Users\crist\OneDrive\Documentos\GitHub\Large-Devaluations-and-CO2"
	}
	if "$usuario" == "J" {
		global dir_base "change here"
	}
}


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
gen grossoutput_ly=grossoutput[_n-1] if country==country[_n-1] & year==year[_n-1]+1

** Add data from penn table ***
merge 1:1 country_code year using "${dir_base}\01-raw-data\penn_world_tables\pwt100_temp.dta", keep(3) nogen

/*-------------------------------------------------------*/
/*-----------------------PRELIMINARIES-------------------*/
/*-------------------------------------------------------*/

/*---------------SET GLOBALS FOR PROGRAM---------------*/
global eventvar="Event" /*Event variable*/
*Event for real event, TFalse for False event.
global monthsafter="6" /*Set Years after Devaluation*/
global monthsbefore="4"/*Set Lags*/
*global outcome1="ln_energy_cost_share" /*Set outcome scope1_eora or scope12_eora*/
global outcome1="energy_cost_share" /*Set outcome scope1_eora or scope12_eora*/
global timevar="year" 
global productvar="countrycode"
global controls="" /*If want to add controls*/

* Generate event for large devaluations
gen Event=0
replace Event=1 if country_code=="ARG" & year==2002
replace Event=1 if country_code=="MEX" & year==1995
replace Event=1 if country_code=="RUS" & year==1998
replace Event=1 if country_code=="FIN" & year==1993
replace Event=1 if country_code=="ISL" & year==2008
replace Event=1 if country_code=="MYS" & year==1997
replace Event=1 if country_code=="IDN" & year==1998
replace Event=1 if country_code=="THA" & year==1998
replace Event=1 if country_code=="KOR" & year==1998
replace Event=1 if country_code=="TUR" & year==1994
replace Event=1 if country_code=="TUR" & year==2001
replace Event=1 if country_code=="BRA" & year==1999
replace Event=1 if country_code=="IND" & year==1991
replace Event=1 if country_code=="COL" & year==2014

* Generate outcomes in log
*gen ln_energy_cost_share=ln((energy_spending/grossoutput)/(1-(energy_spending/grossoutput)))
gen energy_cost_share=energy_spending/grossoutput


* Set a code for each country.
encode country,gen(countrycode)

* Variable for false event:
gen uniform=runiform()
gen Tfalse=0
replace Tfalse=1 if uniform>=0.80

sort country year

* Indicator counting years since large devaluations

by country: gen target=year if $eventvar==1
egen td=min(target), by(country)
*CMonth will count years since devaluation.
gen CMonth=year-td

bysort country: egen EVERe=max(Event)
*keep if EVERe==1
**end points to -1 for balance panel
replace CMonth=$monthsafter if CMonth>=$monthsafter 
replace CMonth=-$monthsbefore if CMonth<-$monthsbefore

replace CMonth=CMonth+50

*Reference category: the month before
char CMonth[omit] 49

****Regressions
global ytitle="Energy Cost per Dollar of Output"

*Main regression
*xi: reghdfe $outcome1 i.CMonth $controls, a($timevar $productvar) cluster($productvar)
xi: reghdfe $outcome1 i.CMonth , a($timevar $productvar) cluster($productvar)

**From here, just moving things around to generate an automatic graph
parmest,norestore

**Generate time variable as years since treatment.
gen time=substr(parm,10,2)
destring time,replace force
replace time=time-50
count
set obs `=r(N) + 1 '
replace time = -1 in `=r(N) + 1 '
foreach x in estimate stderr t p min95 max95{
replace `x'=0 if time==-1
}
keep if estimate<1 & estimate>-1
sort time
twoway (rcap min95 max95 time , lcolor(red*0.2) ) (sc estimate time, msymbol(o) mcolor(red*0.5)  mlcolor(red*0.5) lcolor(red*0.5)) , xline(-1, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) xtitle("Years since large devaluation") ytitle($ytitle) xlabel(-$monthsbefore(1)$monthsafter) legend(ring(0) position(4) order(1 "Point estimate" 2 "95% confidence interval"))
graph export "05-results\Fig1-event_study_costshare_country.pdf", as(pdf) replace
*graph display Graph, ysize(10) xsize(15) margin(tiny) scheme(s1mono) 


