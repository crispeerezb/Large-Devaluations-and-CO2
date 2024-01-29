/*
********************************************************
THIS CODE CREATE A DATA SET WITH GROSS OUTPUT BY COUNTRY
********************************************************
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

/************
Observations:
*************

1) Note that the data used here isn't in the GitHub repository since this data is too big

*/


*==============================================================================*
*                          Gross output by country and industry                *
*==============================================================================*

local start_year = 1990
local end_year = 2009

* Load and save countryXindustry once only
insheet using "${dir_source}\EORA\Eora26_1990_bp\labels_T.txt", tab clear
gen countryXindustry = _n
tostring countryXindustry, replace
save "${dir_temp}\countryXindustry.dta", replace

* Start timer to check loop duration
timer clear 1
timer on 1

foreach year of numlist `start_year'/`end_year' {
    * Load, transform, and save intermediates
    insheet using "${dir_source}\EORA\Eora26_`year'_bp\Eora26_`year'_bp_T.txt", tab clear
    collapse (sum) v1-v4915, fast
    gen one = 1
    reshape long v, i(one) j(countryXindustry)
    rename v intermediates
    drop one
	tostring countryXindustry, replace 
    tempfile intermediates_year
    save "`intermediates_year'", replace

    * Load, transform, and save valueadded
    insheet using "${dir_source}\EORA\Eora26_`year'_bp\Eora26_`year'_bp_VA.txt", tab clear
    collapse (sum) v1-v4915, fast
    gen one = 1
    reshape long v, i(one) j(countryXindustry)
    rename v valueadded
    drop one
	tostring countryXindustry, replace
    merge 1:1 countryXindustry using "`intermediates_year'", assert(3) nogen
	
	* deflate $2014->2019 using GDP deflator from /gdpDeflator
	* source: https://fred.stlouisfed.org/series/GDPDEF
	if `year'==1990{
				replace intermediates      = intermediates      * (112.152/63.416) 
				replace valueadded = valueadded * (112.152/63.416)
				}
			if `year'==1991{
				replace intermediates      = intermediates      * (112.152/65.545) 
				replace valueadded = valueadded * (112.152/65.545)
				}
			if `year'==1992{
				replace intermediates      = intermediates      * (112.152/67.097) 
				replace valueadded = valueadded * (112.152/67.097)
				}
			if `year'==1993{
				replace intermediates      = intermediates      * (112.152/68.676) 
				replace valueadded = valueadded * (112.152/68.676)
				}
			if `year'==1994{
				replace intermediates      = intermediates      * (112.152/70.130) 
				replace valueadded = valueadded * (112.152/70.130)
				}
			if `year'==1995{
				replace intermediates      = intermediates      * (112.152/71.642)
				replace valueadded = valueadded * (112.152/71.642)
				}
			if `year'==1996{
				replace intermediates      = intermediates      * (112.152/72.991) 
				replace valueadded = valueadded * (112.152/72.991)
				}
			if `year'==1997{
				replace intermediates      = intermediates      * (112.152/74.210) 
				replace valueadded = valueadded * (112.152/74.210)
				}
			if `year'==1998{
				replace intermediates      = intermediates      * (112.152/75.063) 
				replace valueadded = valueadded * (112.152/75.063)
				}
			if `year'==1999{
				replace intermediates      = intermediates      * (112.152/76.122) 
				replace valueadded = valueadded * (112.152/76.122)
				}
			if `year'==2000{
				replace intermediates      = intermediates      * (112.152/77.807) 
				replace valueadded = valueadded * (112.152/77.807)
				}
			if `year'==2001{
				replace intermediates      = intermediates      * (112.152/79.683) 
				replace valueadded = valueadded * (112.152/79.683)
				}
			if `year'==2002{
				replace intermediates      = intermediates      * (112.152/80.783) 
				replace valueadded = valueadded * (112.152/80.783)
				}
			if `year'==2003{
				replace intermediates      = intermediates      * (112.152/82.328) 
				replace valueadded = valueadded * (112.152/82.328)
				}
			if `year'==2004{
				replace intermediates      = intermediates      * (112.152/84.569) 
				replace valueadded = valueadded * (112.152/84.569)
				}
			if `year'==2005{
				replace intermediates      = intermediates      * (112.152/87.082)
				replace valueadded = valueadded * (112.152/87.082)
				}
			if `year'==2006{
				replace intermediates      = intermediates      * (112.152/90.000) 
				replace valueadded = valueadded * (112.152/90.000)
				}
			if `year'==2007{
				replace intermediates      = intermediates      * (112.152/92.453) 
				replace valueadded = valueadded * (112.152/92.453)
				}
			if `year'==2008{
				replace intermediates      = intermediates      * (112.152/94.130) 
				replace valueadded = valueadded * (112.152/94.130)
				}
			if `year'==2009{
				replace intermediates      = intermediates      * (112.152/94.852) 
				replace valueadded = valueadded * (112.152/94.852)
				}
			if `year'==2010{
				replace intermediates      = intermediates      * (112.152/95.992) 
				replace valueadded = valueadded * (112.152/95.992)
				}
			if `year'==2011{
				replace intermediates      = intermediates      * (112.152/97.989) 
				replace valueadded = valueadded * (112.152/97.989)
				}
			if `year'==2012{
				replace intermediates      = intermediates      * (112.152/99.713) 
				replace valueadded = valueadded * (112.152/99.713)
				}
			if `year'==2013{
				replace intermediates      = intermediates      * (112.152/101.438) 
				replace valueadded = valueadded * (112.152/101.438)
				}
			if `year' ==2014{
				replace intermediates      = intermediates      * (112.152/103.525)
				replace valueadded = valueadded * (112.152/103.525)
				}
			if `year'==2015{
				replace intermediates      = intermediates      * (112.152/104.677) 
				replace valueadded = valueadded * (112.152/104.677)
				}	
			if `year'==2016{
				replace intermediates      = intermediates      * (112.152/105.363) 
				replace valueadded = valueadded * (112.152/105.363)
				}

    * Calculate grossoutput and save
    gen grossoutput = valueadded + intermediates
    merge 1:1 countryXindustry using "${dir_temp}\countryXindustry.dta", assert(3) nogen
    drop v5
    gen year = `year'
    save "${dir_temp}/gross-output/grossoutput_temp`year'.dta", replace
	
}


* Stop timer and display duration
timer off 1
timer list 1


* Finally we append data
cd "${dir_temp}/gross-output"
use grossoutput_temp1990.dta, clear 

foreach year of numlist 1991/2016 {
    append using grossoutput_temp`year'.dta
}

* Improve format
drop v3 valueadded intermediates
rename v1 country
rename v4 industry
rename v2 country_code
order countryXindustry country country_code industry year grossoutput
sort country country_code year industry

* We save data
save "${output}/data-stata/eora/01-gross_output_country-industry.dta"
