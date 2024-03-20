/*
*****************************************************************************
*****************************************************************************
THIS CODE ESTIMATE EVENT STUDY FOR ENERGY COST_SHARE (COUNTRY-INDUSTRY LEVEL)
*****************************************************************************
*****************************************************************************
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
use "${output}\data-stata\eora\04-electricity-spending.dta", clear

merge 1:1 countryXindustry country country_code industry year using "${output}\data-stata\eora\03-co2-emissions-scope-2-country-industry.dta"


*** define clean and dirty industry ***

egen gross_output_industry = total(grossoutput), by(industry)
egen co2_scope1_industry = total(co2_scope1), by(industry)
gen co2_scope1_rate_industry = co2_scope1_industry/gross_output_industry

summarize co2_scope1_rate, detail
/*
                       co2_scope1_rate
-------------------------------------------------------------
      Percentiles      Smallest
 1%            0              0
 5%     .0152596       .0152596
10%     .0199556       .0199556       Obs                  26
25%     .0248907       .0212821       Sum of wgt.          26

50%     .0703486                      Mean           .2773015
                        Largest       Std. dev.      .7824481
75%      .121782       .2505798
90%     .4387235       .4387235       Variance        .612225
95%      1.17288        1.17288       Skewness       4.233195
99%     3.942306       3.942306       Kurtosis       20.10261

*/

local p25 `r(p25)'
local p75 `r(p75)'


egen co2_scope1_total_industry = total(co2_scope1), by(industry)
egen grossoutput_total_industry = total(grossoutput), by(industry)

gen scope1_rate_aux = co2_scope1_total_industry/grossoutput_total_industry

gen clean_industry = 0
replace clean_industry = 1 if scope1_rate_aux <= `p25'

gen dirty_industry = 0
replace dirty_industry = 1 if scope1_rate_aux >= `p75'

keep if dirty_industry == 1

/*


                               industry |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
             Electricity, Gas and Water |      5,103       14.29       14.29
                         Metal Products |      5,103       14.29       28.57
                   Mining and Quarrying |      5,103       14.29       42.86
Petroleum, Chemical and Non-Metallic .. |      5,103       14.29       57.14
                              Recycling |      5,103       14.29       71.43
           Textiles and Wearing Apparel |      5,103       14.29       85.71
                              Transport |      5,103       14.29      100.00
----------------------------------------+-----------------------------------
                                  Total |     35,721      100.00



*/

*** Generate outcome variable ***
gen ln_energy_cost_share = ln(energy_cost_share)

*** Generate grossoutput variable lagged
sort country year
gen grossoutput_ly=grossoutput[_n-1] if country==country[_n-1] & year==year[_n-1]+1

** Add data from penn table (many-to-one, because master have many times country) ***
merge m:1 country_code year using "${dir_base}\01-raw-data\penn_world_tables\pwt100_temp.dta", keep(3) nogen

/*-------------------------------------------------------*/
/*-----------------------PRELIMINARIES-------------------*/
/*-------------------------------------------------------*/

/*---------------SET GLOBALS FOR PROGRAM---------------*/
global eventvar="Event" /*Event variable*/
*Event for real event, TFalse for False event.
global monthsafter="4" /*Set Years after Devaluation*/
global monthsbefore="4"/*Set Years Lags*/
global outcome1="ln_energy_cost_share" /*Set outcome scope1_eora or scope12_eora*/
global timevar="year" 
global productvar="countrycode"
global productvar1="industry_code"
global productvar2 = "countryXindustry_code"
global controls="lrgdpo" /*If want to add controls*/

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
*replace Event=1 if country_code=="IND" & year==1991
*replace Event=1 if country_code=="COL" & year==2014

* Set a code for reg
encode industry ,gen(industry_code)
encode country,gen(countrycode)
encode countryXindustry, gen(countryXindustry_code)

* Variable for false event:
gen uniform=runiform()
gen Tfalse=0
replace Tfalse=1 if uniform>=0.80

sort country countryXindustry year

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
xi: reghdfe $outcome1 i.CMonth $controls, a($timevar $productvar) cluster($productvar2)
*xi: reghdfe $outcome1 i.CMonth , a($timevar $productvar $productvar1) cluster($productvar)

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
twoway (sc estimate time, mcolor(orange) mlcolor(orange) lcolor(orange) connect(direct)) (rcap min95 max95 time , lcolor(gs10) ), xline(-1, lpattern(dash) lcolor(black)) yline(0) xtitle("Years since Large Devaluation") ytitle($ytitle) xlabel(-$monthsbefore(1)$monthsafter) legend(ring(0) position(8) order(1 "Point estimate" 2 "95% confidence interval"))

graph export "${results}\eora\event-study-for-large-devaluations\05-scope1_country-industry(dirty_industry).pdf", as(pdf) replace


*graph display Graph, ysize(10) xsize(15) margin(tiny) scheme(s1mono) 


