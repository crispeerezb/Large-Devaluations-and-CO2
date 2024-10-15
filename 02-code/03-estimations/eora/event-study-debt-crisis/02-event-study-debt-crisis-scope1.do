/*-------------------------------------------*/
/*-------Event Study: Debt Crises------------*/
/*-------------------------------------------*/

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


* drop those countries with zero emissions
/*drop if country == "Armenia" | ///
         country == "Azerbaijan" | ///
         country == "Belarus" | ///
         country == "Former USSR" | ///
         country == "Georgia" | ///
         country == "Kazakhstan" | ///
         country == "Kyrgyzstan" | ///
         country == "Liechtenstein" | ///
         country == "Moldova" | ///
         country == "Monaco" | ///
         country == "Montenegro" | ///
         country == "Russia" | ///
         country == "San Marino" | ///
         country == "Serbia" | ///
         country == "South Sudan" | ///
         country == "Statistical Discrepancies" | ///
         country == "Sudan" | ///
         country == "Tajikistan" | ///
         country == "Turkmenistan" | ///
         country == "Ukraine" | ///
         country == "Uzbekistan"
*/
		 
*** keep till 2009 ***
keep if year <= 2009

*** Generate grossoutput variable lagged
sort country year
gen grossoutput_ly=grossoutput[_n-1] if country==country[_n-1] & year==year[_n-1]+1

*** Add data from penn table ***
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
global outcome1="ln_co2_scope1" /*Set outcome scope1_eora or scope12_eora*/
global timevar="year" 
global productvar="countrycode"
global controls="lrgdpo lemp lrnna" /*If want to add controls*/

*** add debt crises events ***
merge m:1 country_code year using "${output}\data-stata\financial-crisis\sovereign_debt_crisis.dta"

rename sovereign_debt_crisis_event Event
replace Event = 0 if Event ==.

drop if _merge==2
drop _merge

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
global ytitle="Log Scope 1"

*Main regression
xi: reghdfe $outcome1 i.CMonth $controls, a($timevar $productvar) cluster($productvar)
*xi: reghdfe $outcome1 i.CMonth , a($timevar $productvar) cluster($productvar)

**From here, just moving things around to generate an automatic graph
parmest,norestore

drop if parm == "_cons"
drop if parm == "lrgdpo"
drop if parm == "lemp"
drop if parm == "lrnna"

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
twoway (sc estimate time, mcolor(orange) mlcolor(orange) lcolor(orange) connect(direct)) ///
       (rcap min95 max95 time, lcolor(gs10)), ///
       xline(-1, lpattern(dash) lcolor(black)) ///
       yline(0) ///
       xtitle("Years since Debt Crisis", size(medium)) ///
       ytitle($ytitle, size(medium)) ///
       xlabel(-$monthsbefore(1)$monthsafter) ///
       legend(ring(0) position(4) order(1 "Point estimate" 2 "95% confidence interval")) ///
       graphregion(margin(large)) ///
       xsize(20) ysize(10)


*** save graph ***
graph export "${results}\eora\event-study-for-debt-crisis\ES-D-Scope-1.pdf", as(pdf) replace



