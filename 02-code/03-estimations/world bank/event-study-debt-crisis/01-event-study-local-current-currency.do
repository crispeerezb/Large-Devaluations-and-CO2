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


*** set path where i store the data ***
global wd "${dir_base}\01-code"
global dir_temp "${dir_base}\03-temp"
global dir_source "C:\Users\crist\Dropbox Dropbox\Cristóbal Pérez Barraza\A-Large Devaluations and CO2\DataRaw" // note this one is not in the repository
global output "${dir_base}\04-output"


*** load data set ***
use "${output}\data-stata\eora\02-co2-emissions-scope-1-country-industry.dta", clear

merge 1:1 countryXindustry country country_code industry year using "${output}\data-stata\eora\03-co2-emissions-scope-2-country-industry.dta"

drop _merge

merge 1:1 countryXindustry country country_code industry year using "${output}/data-stata/eora/06-gross_output_country-industry_v2.dta"

*** We collapse data to have data country-year level
collapse (sum) co2_scope1 co2_scope2 grossoutput_local_current, by(country country_code year)

*** just to recicle code ***
rename grossoutput_local_current grossoutput
drop if grossoutput ==0


/*
encode country, gen(country_num)
xtset country_num year

gen var_gross_output = (grossoutput - grossoutput[_n-1]) / grossoutput[_n-1] * 100 if country_num == country_num[_n-1]
merge m:1 country_code year using "${output}\data-stata\financial-crisis\sistemic_banking_crisis.dta"

drop if _merge == 2

export excel using "${dir_temp}\grossoutput_and_crises.xlsx", firstrow(variables) replace

*/

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

* keep till 2009
keep if year <= 2009

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
merge 1:1 country_code year using "${dir_base}\01-raw-data\penn_world_tables\pwt100_temp.dta", keep(3) nogen

/*-------------------------------------------------------*/
/*-----------------------PRELIMINARIES-------------------*/
/*-------------------------------------------------------*/

/*---------------SET GLOBALS FOR PROGRAM---------------*/
global eventvar="Event" /*Event variable*/
*Event for real event, TFalse for False event.
global monthsafter="4" /*Set Years after Devaluation*/
global monthsbefore="4"/*Set Lags*/
global outcome1="ln_gross_output" /*Set outcome scope1_eora or scope12_eora*/
global timevar="year" 
global productvar="countrycode"
global controls="lrgdpo" /*If want to add controls*/

***
merge m:1 country_code year using "${output}\data-stata\financial-crisis\sovereign_debt_crisis.dta"

rename sovereign_debt_crisis_event Event
replace Event = 0 if Event ==.

drop if _merge==2
drop _merge

/*
* Generate event for large devaluations
gen Event = 0
replace Event = 1 if country_code=="ARM" & year==1994
*replace Event = 1 if country_code=="COG" & year==1992
replace Event = 1 if country_code=="LVA" & year==1995
*replace Event = 1 if country_code=="POL" & year==1992
replace Event = 1 if country_code=="ZMB" & year==1995
replace Event = 1 if country_code=="ALB" & year==1994
replace Event = 1 if country_code=="ARG" & year==1995
replace Event = 1 if country_code=="ARG" & year==2001
replace Event = 1 if country_code=="AUT" & year==2008
replace Event = 1 if country_code=="AZE" & year==1995
replace Event = 1 if country_code=="BDI" & year==1994
replace Event = 1 if country_code=="BEL" & year==2008
replace Event = 1 if country_code=="BFA" & year==1990
replace Event = 1 if country_code=="BGR" & year==1996
*replace Event = 1 if country_code=="BIH" & year==1992
replace Event = 1 if country_code=="BLR" & year==1995
replace Event = 1 if country_code=="BOL" & year==1994
*replace Event = 1 if country_code=="BRA" & year==1990
replace Event = 1 if country_code=="BRA" & year==1994
replace Event = 1 if country_code=="CAF" & year==1995
replace Event = 1 if country_code=="CHE" & year==2008
replace Event = 1 if country_code=="CHN" & year==1998
replace Event = 1 if country_code=="CMR" & year==1995
replace Event = 1 if country_code=="COD" & year==1994
*replace Event = 1 if country_code=="COD" & year==1991
replace Event = 1 if country_code=="COL" & year==1998
*replace Event = 1 if country_code=="CPV" & year==1993
replace Event = 1 if country_code=="CRI" & year==1994
replace Event = 1 if country_code=="CYP" & year==2011
replace Event = 1 if country_code=="CZE" & year==1996
replace Event = 1 if country_code=="DEU" & year==2008
*replace Event = 1 if country_code=="DJI" & year==1991
replace Event = 1 if country_code=="DNK" & year==2008
replace Event = 1 if country_code=="DOM" & year==2003
*replace Event = 1 if country_code=="DZA" & year==1990
replace Event = 1 if country_code=="ECU" & year==1998
*replace Event = 1 if country_code=="ERI" & year==1993
replace Event = 1 if country_code=="ESP" & year==2008
*replace Event = 1 if country_code=="EST" & year==1992
*replace Event = 1 if country_code=="FIN" & year==1991
replace Event = 1 if country_code=="FRA" & year==2008
replace Event = 1 if country_code=="GBR" & year==2007
*replace Event = 1 if country_code=="GEO" & year==1991
*replace Event = 1 if country_code=="GIN" & year==1993
replace Event = 1 if country_code=="GRC" & year==2008
*replace Event = 1 if country_code=="GUY" & year==1993
replace Event = 1 if country_code=="HRV" & year==1998
replace Event = 1 if country_code=="HTI" & year==1994
*replace Event = 1 if country_code=="HUN" & year==1991
replace Event = 1 if country_code=="HUN" & year==2008
replace Event = 1 if country_code=="IDN" & year==1997
*replace Event = 1 if country_code=="IND" & year==1993
replace Event = 1 if country_code=="IRL" & year==2008
replace Event = 1 if country_code=="ISL" & year==2008
replace Event = 1 if country_code=="ITA" & year==2008
replace Event = 1 if country_code=="JAM" & year==1996
replace Event = 1 if country_code=="JPN" & year==1997
replace Event = 1 if country_code=="KAZ" & year==2008
*replace Event = 1 if country_code=="KEN" & year==1992
replace Event = 1 if country_code=="KGZ" & year==1995
replace Event = 1 if country_code=="KOR" & year==1997
*replace Event = 1 if country_code=="LBN" & year==1990
*replace Event = 1 if country_code=="LBR" & year==1991
replace Event = 1 if country_code=="LTU" & year==1995
replace Event = 1 if country_code=="LUX" & year==2008
replace Event = 1 if country_code=="LVA" & year==2008
replace Event = 1 if country_code=="MDA" & year==2014
replace Event = 1 if country_code=="MEX" & year==1994
*replace Event = 1 if country_code=="MKD" & year==1993
replace Event = 1 if country_code=="MNG" & year==2008
replace Event = 1 if country_code=="MYS" & year==1997
replace Event = 1 if country_code=="NGA" & year==2009
*replace Event = 1 if country_code=="NGA" & year==1991
*replace Event = 1 if country_code=="NIC" & year==1990
replace Event = 1 if country_code=="NIC" & year==2000
replace Event = 1 if country_code=="NLD" & year==2008
*replace Event = 1 if country_code=="NOR" & year==1991
replace Event = 1 if country_code=="PHL" & year==1997
replace Event = 1 if country_code=="PRT" & year==2008
replace Event = 1 if country_code=="PRY" & year==1995
replace Event = 1 if country_code=="ROU" & year==1998
replace Event = 1 if country_code=="RUS" & year==2008
replace Event = 1 if country_code=="RUS" & year==1998
*replace Event = 1 if country_code=="SLE" & year==1990
*replace Event = 1 if country_code=="STP" & year==1992
replace Event = 1 if country_code=="SVK" & year==1998
replace Event = 1 if country_code=="SVN" & year==2008
*replace Event = 1 if country_code=="SVN" & year==1992
replace Event = 1 if country_code=="SWE" & year==2008
*replace Event = 1 if country_code=="SWE" & year==1991
replace Event = 1 if country_code=="SWZ" & year==1995
*replace Event = 1 if country_code=="TCD" & year==1992
*replace Event = 1 if country_code=="TGO" & year==1993
replace Event = 1 if country_code=="THA" & year==1997
*replace Event = 1 if country_code=="TUN" & year==1991
replace Event = 1 if country_code=="TUR" & year==2000
replace Event = 1 if country_code=="UGA" & year==1994
replace Event = 1 if country_code=="UKR" & year==2008
replace Event = 1 if country_code=="UKR" & year==2014
replace Event = 1 if country_code=="UKR" & year==1998
replace Event = 1 if country_code=="URY" & year==2002
replace Event = 1 if country_code=="USA" & year==2007
replace Event = 1 if country_code=="VEN" & year==1994
replace Event = 1 if country_code=="VNM" & year==1997
replace Event = 1 if country_code=="YEM" & year==1996
replace Event = 1 if country_code=="ZWE" & year==1995
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
global ytitle="Log Cost Energy rate"

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
twoway (sc estimate time, mcolor(orange) mlcolor(orange) lcolor(orange) connect(direct)) (rcap min95 max95 time , lcolor(gs10) ), xline(-1, lpattern(dash) lcolor(black)) yline(0) xtitle("Years since Systemic Banking Crisis") ytitle("Log Scope 1 rates") xlabel(-$monthsbefore(1)$monthsafter) legend(ring(0) position(8) order(1 "Point estimate" 2 "95% confidence interval"))



