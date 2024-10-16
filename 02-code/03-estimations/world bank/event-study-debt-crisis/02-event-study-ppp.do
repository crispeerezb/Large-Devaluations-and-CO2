/*
************************************************************
************************************************************
THIS CODE ESTIMATE EVENT STUDY FOR EMISSIONS BY COUNTRY LEVEL
*************************************************************
*************************************************************
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


*** set path where i store the data ***
global wd "${dir_base}\01-code"
global dir_temp "${dir_base}\03-temp"
global dir_source "C:\Users\crist\Dropbox Dropbox\Cristóbal Pérez Barraza\A-Large Devaluations and CO2\DataRaw" // note this one is not in the repository
global output "${dir_base}\04-output"
global results "${dir_base}\05-results"


*** load data set ***
use "${output}\data-stata\eora\02-co2-emissions-scope-1-country-industry.dta", clear

merge 1:1 countryXindustry country country_code industry year using "${output}/data-stata/eora/03-co2-emissions-scope-2-country-industry.dta"

drop _merge

merge m:m country country_code year using "${output}/data-stata/imf/01-exchange-rate.dta"

*** we let everything in local currency
gen grossoutput_local_currency = exchange_rate*grossoutput

*** We collapse data to have data country-year level
collapse (sum) co2_scope1 co2_scope2 grossoutput_local_currency, by(country country_code year)

merge m:m country country_code year using "${output}/data-stata/imf/02-ppp-rate.dta"

drop _merge

*** we add ppp rates ***


*** just to recicle code ***
gen grossoutput = grossoutput_local_currency/ppp_rate
drop if missing(country_code)

* careful from here
/*
* option 1):
egen mean_product = mean(grossoutput), by(country)
drop grossoutput
rename mean_product grossoutput

* option 2):
gen inicial_gross_output =.
replace inicial_gross_output = grossoutput if year == 1990
bysort country (year): replace inicial_gross_output = inicial_gross_output[_n-1] if inicial_gross_output == .
drop grossoutput 
rename inicial_gross_output grossoutput
* to here
*/

*** gen scope 1 and 2 rates
gen ln_co2_scope1_rate = log(co2_scope1/grossoutput)
gen ln_co2_scope2_rate = log(co2_scope2/grossoutput)
gen ln_co2_scope12_rate = log((co2_scope1+co2_scope2)/grossoutput)
gen ln_co2_scope1 = log(co2_scope1)
gen ln_co2_scope2 = log(co2_scope2)
gen ln_co2_scope12 = log(co2_scope1+co2_scope2)
gen ln_gross_output = log(grossoutput)


*** Generate grossoutput variable lagged
sort country year
gen grossoutput_ly=grossoutput[_n-1] if country==country[_n-1] & year==year[_n-1]+1

** Add data from penn table ***
merge m:m country_code year using "${dir_base}\01-raw-data\penn_world_tables\pwt100_temp.dta", keep(3) nogen


drop if country == "Afghanistan" | ///
         country == "Belarus" | ///
         country == "Bosnia and Herzegovina" | ///
         country == "Cayman Islands" | ///
         country == "Georgia" | ///
         country == "Kyrgyzstan" | ///
         country == "Moldova" | ///
         country == "Montenegro" | ///
         country == "San Marino" | ///
         country == "Somalia" | ///
         country == "Turkmenistan" | ///
         country == "Uzbekistan"

/*-------------------------------------------------------*/
/*-----------------------PRELIMINARIES-------------------*/
/*-------------------------------------------------------*/

/*---------------SET GLOBALS FOR PROGRAM---------------*/
global eventvar="Event" /*Event variable*/
*Event for real event, TFalse for False event.
global monthsafter="4" /*Set Years after Devaluation*/
global monthsbefore="4"/*Set Lags*/
global outcome1="ln_gross_output" /*Set outcome ln_co2_scope1_rate or ln_co2_scope2_rate*/
global timevar="year" 
global productvar="countrycode"
global controls="lrgdpo" /*If want to add controls*/

* Generate event for large devaluations

merge m:1 country_code year using "${output}\data-stata\financial-crisis\sistemic_banking_crisis.dta"

rename sis_banking_crisis_event Event
replace Event = 0 if Event ==.

drop if _merge==2
drop _merge

/*
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
*/

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
**end points to -1 for balance panel
replace CMonth=$monthsafter if CMonth>=$monthsafter 
replace CMonth=-$monthsbefore if CMonth<-$monthsbefore

replace CMonth=CMonth+50

*Reference category: the month before
char CMonth[omit] 49

****Regressions
global ytitle="Log Scope 1 Emissions Rate"

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

* just to graph
drop if parm == "_cons"
drop if parm == "lrgdpo"

twoway (sc estimate time, mcolor(orange) mlcolor(orange) lcolor(orange) connect(direct)) (rcap min95 max95 time , lcolor(gs10)), xline(-1, lpattern(dash) lcolor(black)) yline(0) xtitle("Years since Systemic Banking Crisis") ytitle($ytitle) xlabel(-$monthsbefore(1)$monthsafter) legend(ring(0) position(8) order(1 "Point estimate" 2 "95% confidence interval"))

*graph export "${results}\eora\event-study-for-large-devaluations\03-scope1_country.pdf", as(pdf) replace

*graph twoway (scatter estimate time, mcolor(orange) mlcolor(orange) lcolor(orange) connect(direct) yscale(r(0.2 -0.4))) (rcap min95 max95 time , lcolor(gs10)) 

*graph display Graph, ysize(10) xsize(15) margin(tiny) scheme(s1mono)


