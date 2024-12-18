/*-----------------------------------------------*/
/*-------Event Study: Currency Crises------------*/
/*-----------------------------------------------*/

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
use "${output}\data-stata\eora\06-EORA-COUNTRY-INDUSTRY-1990-2009_V2.dta", clear

*** We collapse data to have data country-year level
collapse (sum) co2_scope1 co2_scope2 grossoutput grossoutput_LC grossoutput_PPP, by(country country_code year)

*** Drop these countries which have cero emissions data ***
/*drop if country == "Afghanistan" | ///
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
*/
		 
*** Keep just before 2009 ***		 
keep if year <= 2009

*** Generate grossoutput variable lagged
sort country year
gen grossoutput_ly=grossoutput[_n-1] if country==country[_n-1] & year==year[_n-1]+1

** Add data from penn table ***
merge 1:1 country_code year using "${dir_base}\01-raw-data\penn_world_tables\pwt100_temp.dta", keep(3) nogen

*** gen scope 1 and 2 rates
gen ln_co2_scope1_rate = log(co2_scope1/grossoutput_PPP)
gen ln_co2_scope2_rate = log(co2_scope2/grossoutput_PPP)
gen ln_co2_scope12_rate = log((co2_scope1+co2_scope2)/grossoutput_PPP)
gen ln_co2_scope1 = log(co2_scope1)
gen ln_co2_scope2 = log(co2_scope2)
gen ln_co2_scope12 = log(co2_scope1+co2_scope2)
gen ln_gross_output = log(grossoutput_PPP)

/*-------------------------------------------------------*/
/*-----------------------PRELIMINARIES-------------------*/
/*-------------------------------------------------------*/

/*---------------SET GLOBALS FOR PROGRAM---------------*/
global eventvar="Event" /*Event variable*/
*Event for real event, TFalse for False event.
global monthsafter="5" /*Set Years after Devaluation*/
global monthsbefore="5"/*Set Lags*/
global outcome1="ln_co2_scope1_rate" /*Set outcome ln_co2_scope1_rate or ln_co2_scope2_rate*/
global timevar="year" 
global productvar="countrycode"
global controls="lrgdpo lemp lrnna" /*If want to add controls*/

* Generate event for large devaluations
gen Event=0
replace Event=1 if country_code=="ARG" & year==2002
replace Event=1 if country_code=="MEX" & year==1995
replace Event=1 if country_code=="RUS" & year==1998
replace Event=1 if country_code=="FIN" & year==1993
*replace Event=1 if country_code=="ISL" & year==2008
replace Event=1 if country_code=="MYS" & year==1997
replace Event=1 if country_code=="IDN" & year==1998
replace Event=1 if country_code=="THA" & year==1998
replace Event=1 if country_code=="KOR" & year==1998
replace Event=1 if country_code=="TUR" & year==1994
replace Event=1 if country_code=="TUR" & year==2001
replace Event=1 if country_code=="BRA" & year==1999
replace Event=1 if country_code=="IND" & year==1991
*replace Event=1 if country_code=="COL" & year==2014

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
global ytitle="Log Scope 1 Rate"

*Main regression
xi: reghdfe $outcome1 i.CMonth $controls, a($timevar $productvar) cluster($productvar)
*xi: reghdfe $outcome1 i.CMonth , a($timevar $productvar) cluster($productvar)

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


* just to improve the way we show it
drop if parm == "_ICMonth_44" | parm == "_ICMonth_45"
global monthsbefore="4"/*Set Lags*/

sort time

* just to graph
drop if parm == "_cons"
drop if parm == "lrgdpo"
drop if parm == "lemp"
drop if parm == "lrnna"

twoway (sc estimate time, mcolor(orange) mlcolor(orange) lcolor(orange) connect(direct)) ///
       (rcap min95 max95 time, lcolor(gs10)), ///
       xline(-1, lpattern(dash) lcolor(black)) ///
       yline(0) ///
       xtitle("Years since Large Devaluation", size(medium)) ///
       ytitle($ytitle, size(medium)) ///
       xlabel(-$monthsbefore(1)$monthsafter) ///
       legend(ring(0) position(4) order(1 "Point estimate" 2 "95% confidence interval")) ///
       graphregion(margin(large)) ///
       xsize(20) ysize(10)


graph export "${results}\eora\event-study-for-large-devaluations\ES-C-Scope-1 (rate).pdf", as(pdf) replace


