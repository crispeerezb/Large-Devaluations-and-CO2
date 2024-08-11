**** THIS DO FILE IS FOR STATISTICS ABOUT EMISSIONS FROM EORA ****

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


*************************
*** Industry Analysis ***
*************************

* load data set 
use "${output}\data-stata\eora\05-EORA-COUNTRY-INDUSTRY-1990-2016.dta", clear

* collapse data set to get industry level emissions
collapse (sum) grossoutput co2_scope1 co2_scope2, by(industry year)
gen co2_scope12 = co2_scope1 + co2_scope2

* just drop those observation that we do not need
drop if industry == "Total"

* generate co2 intensity for industry
gen co2_scope1_rate = co2_scope1/grossoutput 
gen co2_scope2_rate = co2_scope2/grossoutput 
gen co2_scope12_rate = co2_scope12/grossoutput

* sort data
sort year industry

graph hbar (mean) co2_scope1_rate if year == 2016, over(industry) 
	   

************************
*** Country Analysis ***
************************
	   
* load data set 
use "${output}\data-stata\eora\05-EORA-COUNTRY-INDUSTRY-1990-2016.dta", clear

* collapse data set to get country level emissions
collapse (sum) grossoutput co2_scope1 co2_scope2, by(country country_code year)
gen co2_scope12 = co2_scope1 + co2_scope2

* generate co2 intensity for industry
gen co2_scope1_rate = (co2_scope1/grossoutput) 
gen co2_scope2_rate = (co2_scope2/grossoutput) 
gen co2_scope12_rate = (co2_scope12/grossoutput)

* graph 
twoway (connected  co2_scope1_rate co2_scope2_rate year if country_code == "COL"), xline(2014) ytitle("CO2 Emissions") xtitle("Year") title("Colombia") name(COL, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "MEX"), xline(1995) ytitle("CO2 Emissions") xtitle("Year") title("Mexico") name(MEX, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "RUS"), xline(1998) ytitle("CO2 Emissions") xtitle("Year") title("Russia") name(RUS, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "FIN"), xline(1993) ytitle("CO2 Emissions") xtitle("Year") title("Findland") name(FIN, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "ISL"), xline(2014)  ytitle("CO2 Emissions") xtitle("Year")title("Island") name(ISL, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "MYS"), xline(1997) ytitle("CO2 Emissions") xtitle("Year") title("Malaysa") name(MYS, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "IDN"), xline(1998) ytitle("CO2 Emissions") xtitle("Year") title("Indonesia") name(IDN, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "JPN"), xline(1998) ytitle("CO2 Emissions") xtitle("Year") title("Japan") name(IDN, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "THA"), xline(1998) ytitle("CO2 Emissions") xtitle("Year") title("Thailand") name(THA, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "KOR"), xline(1998) ytitle("CO2 Emissions") xtitle("Year") title("Korea") name(KOR, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "TUR"), xline(1994 2001) ytitle("CO2 Emissions") xtitle("Year") title("Turkey") name(TUR, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "BRA"), xline(1992 1999 2015) ytitle("CO2 Emissions") xtitle("Year") title("Brasil") name(BRA, replace)

twoway (connected co2_scope1_rate co2_scope2_rate year if country_code == "IND"), xline(1991) title("India") ytitle("CO2 Emissions") xtitle("Year") name(IND, replace)


*************************
*** Colombia Analysis ***
*************************

* load data set 
use "${output}\data-stata\eora\05-EORA-COUNTRY-INDUSTRY-1990-2016.dta", clear
	   
* collapse data set to get country level emissions
gen co2_scope12 = co2_scope1 + co2_scope2

* generate co2 intensity for industry
gen co2_scope1_rate = co2_scope1/grossoutput 
gen co2_scope2_rate = co2_scope2/grossoutput 
gen co2_scope12_rate = co2_scope12/grossoutput	   
	 
keep if country_code == "COL"
keep if year == 2013 | year == 2014 | year == 2015

tostring year, replace

graph hbar co2_scope12_rate, over(year) over(industry) ///
bar(1, color(blue)) bar(2, color(red)) ///
title("CO2 Intensity by Industry") ///
ytitle("CO2 Intensity")


***********************
*** Brasil Analysis ***
***********************

* load data set 
use "${output}\data-stata\eora\05-EORA-COUNTRY-INDUSTRY-1990-2016.dta", clear
	   
* collapse data set to get country level emissions
gen co2_scope12 = co2_scope1 + co2_scope2

* generate co2 intensity for industry
gen co2_scope1_rate = co2_scope1/grossoutput 
gen co2_scope2_rate = co2_scope2/grossoutput 
gen co2_scope12_rate = co2_scope12/grossoutput	   
	 
keep if country_code == "BRA"
keep if year == 1998 | year == 1999 | year == 2000

tostring year, replace

graph hbar co2_scope12_rate, over(year) over(industry) ///
bar(1, color(blue)) bar(2, color(red)) ///
title("CO2 Intensity by Industry") ///
ytitle("CO2 Intensity")

	   
*************************
*** Indonesia Analysis ***
*************************

* load data set 
use "${output}\data-stata\eora\05-EORA-COUNTRY-INDUSTRY-1990-2016.dta", clear
	   
* collapse data set to get country level emissions
gen co2_scope12 = co2_scope1 + co2_scope2

* generate co2 intensity for industry
gen co2_scope1_rate = co2_scope1/grossoutput 
gen co2_scope2_rate = co2_scope2/grossoutput 
gen co2_scope12_rate = co2_scope12/grossoutput	   
	 
keep if country_code == "IDN"
keep if year == 1997 | year == 1998 | year == 1999

tostring year, replace

graph hbar co2_scope12_rate, over(year) over(industry) ///
bar(1, color(blue)) bar(2, color(red)) ///
title("CO2 Intensity by Industry") ///
ytitle("CO2 Intensity")

*************************
*** Thailand Analysis ***
*************************

* load data set 
use "${output}\data-stata\eora\05-EORA-COUNTRY-INDUSTRY-1990-2016.dta", clear
	   
* collapse data set to get country level emissions
gen co2_scope12 = co2_scope1 + co2_scope2

* generate co2 intensity for industry
gen co2_scope1_rate = co2_scope1/grossoutput 
gen co2_scope2_rate = co2_scope2/grossoutput 
gen co2_scope12_rate = co2_scope12/grossoutput	   
	 
keep if country_code == "THA"
keep if year == 1997 | year == 1998 | year == 1999

tostring year, replace

graph hbar co2_scope12_rate, over(year) over(industry) ///
bar(1, color(blue)) bar(2, color(red)) ///
title("CO2 Intensity by Industry") ///
ytitle("CO2 Intensity")

***********************
*** Turkey Analysis ***
***********************

* load data set 
use "${output}\data-stata\eora\05-EORA-COUNTRY-INDUSTRY-1990-2016.dta", clear
	   
* collapse data set to get country level emissions
gen co2_scope12 = co2_scope1 + co2_scope2

* generate co2 intensity for industry
gen co2_scope1_rate = co2_scope1/grossoutput 
gen co2_scope2_rate = co2_scope2/grossoutput 
gen co2_scope12_rate = co2_scope12/grossoutput	   
	 
keep if country_code == "TUR"
keep if year == 2000 | year == 2001 | year == 2002

tostring year, replace

graph hbar co2_scope12_rate, over(year) over(industry) ///
bar(1, color(blue)) bar(2, color(red)) ///
title("CO2 Intensity by Industry") ///
ytitle("CO2 Intensity")


**********************
*** Korea Analysis ***
**********************

* load data set 
use "${output}\data-stata\eora\05-EORA-COUNTRY-INDUSTRY-1990-2016.dta", clear
	   
* collapse data set to get country level emissions
gen co2_scope12 = co2_scope1 + co2_scope2

* generate co2 intensity for industry
gen co2_scope1_rate = co2_scope1/grossoutput 
gen co2_scope2_rate = co2_scope2/grossoutput 
gen co2_scope12_rate = co2_scope12/grossoutput	   
	 
keep if country_code == "KOR"
keep if year == 1997 | year == 1998 | year == 1999

tostring year, replace

graph hbar co2_scope12_rate, over(year) over(industry) ///
bar(1, color(blue)) bar(2, color(red)) ///
title("CO2 Intensity by Industry") ///
ytitle("CO2 Intensity")


* =============================================================================*
* =========================== check emissions =================================*
* =============================================================================*

* load data set 
use "${output}\data-stata\eora\05-EORA-COUNTRY-INDUSTRY-1990-2016.dta", clear


	   
* collapse data set to get country level emissions
gen co2_scope12 = co2_scope1 + co2_scope2
collapse co2_scope12 co2_scope1 co2_scope2 grossoutput, by(country country_code year)

* keep grossoutput in millon dollas
replace grossoutput = grossoutput/1000


**************************
*** Indonesia Analysis ***
**************************

twoway (connected co2_scope1 year if country_code == "IDN"), xline(1998) ytitle("CO2 Emissions") xtitle("Year") title("Indonesia") name(IDN, replace)

twoway (connected grossoutput year if country_code == "IDN"), xline(1998) ytitle("Gross Output") xtitle("Year") title("Indonesia") name(IDN, replace)


*************************
*** Thailand Analysis ***
*************************

twoway (connected co2_scope1 year if country_code == "THA"), xline(1998) ytitle("CO2 Emissions") xtitle("Year") title("Thailand") name(IDN, replace)

twoway (connected grossoutput year if country_code == "THA"), xline(1998) ytitle("Gross Output") xtitle("Year") title("Thailand") name(IDN, replace)


***********************
*** Turkey Analysis ***
***********************

twoway (connected co2_scope1 year if country_code == "TUR"), xline(1998) ytitle("CO2 Emissions") xtitle("Year") title("Turkey") name(IDN, replace)

twoway (connected grossoutput year if country_code == "TUR"), xline(1998) ytitle("Gross Output") xtitle("Year") title("Turkey") name(IDN, replace)