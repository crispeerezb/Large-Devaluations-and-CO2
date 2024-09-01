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
local end_year = 2016

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

foreach year of numlist 1991/2009 {
    append using grossoutput_temp`year'.dta
}

* Improve format: rename variables and drop those that we don't need anymore
drop v3 valueadded intermediates
rename v1 country
rename v4 industry
rename v2 country_code
order countryXindustry country country_code industry year grossoutput
sort country country_code year industry
drop if country == "Statistical Discrepancies"

* add deflator and exchange rate data
merge m:1 country_code year using "${output}/data-stata/world bank/02-gdp_deflator.dta"

* we drop those countries that are not in master data set
drop if _merge == 2
drop _merge

* add exchange rate data set
merge m:m country_code year using "${output}/data-stata/imf/01-exchange-rate.dta"

* we drop those countries that are not in master data set
drop if _merge == 2
drop _merge

sort country industry year

* generate grossoutput variable in currente and local currency
gen grossoutput_local_current = (grossoutput*exchange_rate*gdp_deflator_adj)

* keep just essential variables
keep countryXindustry country country_code industry year grossoutput_local_current

/*

                  country |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
              Afghanistan |         10        0.31        0.31 -> drop
                  Albania |         18        0.56        0.87
                  Algeria |         20        0.62        1.49
                   Angola |         20        0.62        2.11
                  Antigua |         20        0.62        2.73
                Argentina |         20        0.62        3.35
                  Armenia |         17        0.53        3.88
                    Aruba |         20        0.62        4.50
                Australia |         20        0.62        5.12
                  Austria |         20        0.62        5.74
               Azerbaijan |         18        0.56        6.30
                  Bahamas |         20        0.62        6.92
                  Bahrain |         20        0.62        7.54
               Bangladesh |         20        0.62        8.16
                 Barbados |         20        0.62        8.78
                  Belarus |         16        0.50        9.28 -> drop
                  Belgium |         20        0.62        9.90
                   Belize |         20        0.62       10.52
                    Benin |         20        0.62       11.14
                  Bermuda |         20        0.62       11.76
                   Bhutan |         20        0.62       12.38
                  Bolivia |         20        0.62       13.00
   Bosnia and Herzegovina |         13        0.40       13.41 -> drop
                 Botswana |         20        0.62       14.03
                   Brazil |         20        0.62       14.65
                   Brunei |         20        0.62       15.27
                 Bulgaria |         19        0.59       15.86
             Burkina Faso |         20        0.62       16.48
                  Burundi |         20        0.62       17.10
                 Cambodia |         20        0.62       17.72
                 Cameroon |         20        0.62       18.34
                   Canada |         20        0.62       18.96
               Cape Verde |         20        0.62       19.58
           Cayman Islands |          4        0.12       19.71 -> drop
 Central African Republic |         20        0.62       20.33
                     Chad |         20        0.62       20.95
                    Chile |         20        0.62       21.57
                    China |         20        0.62       22.19
                 Colombia |         20        0.62       22.81
                    Congo |         20        0.62       23.43
               Costa Rica |         20        0.62       24.05
                  Croatia |         18        0.56       24.61
                   Cyprus |         20        0.62       25.23
           Czech Republic |         17        0.53       25.76
                  Denmark |         20        0.62       26.38
       Dominican Republic |         20        0.62       27.00
                  Ecuador |         20        0.62       27.62
                    Egypt |         20        0.62       28.24
              El Salvador |         20        0.62       28.86
                  Eritrea |         18        0.56       29.42
                  Estonia |         17        0.53       29.95
                 Ethiopia |         20        0.62       30.57
                     Fiji |         20        0.62       31.19
                  Finland |         20        0.62       31.81
                   France |         20        0.62       32.43
         French Polynesia |         20        0.62       33.05
                    Gabon |         20        0.62       33.67
                   Gambia |         20        0.62       34.30
                  Georgia |         14        0.43       34.73 -> drop
                  Germany |         20        0.62       35.35
                    Ghana |         20        0.62       35.97
                   Greece |         20        0.62       36.59
                Greenland |         20        0.62       37.21
                Guatemala |         20        0.62       37.83
                   Guinea |         20        0.62       38.45
                   Guyana |         20        0.62       39.08
                    Haiti |         20        0.62       39.70
                 Honduras |         10        0.31       40.01
                Hong Kong |         20        0.62       40.63
                  Hungary |         20        0.62       41.25
                  Iceland |         20        0.62       41.87
                    India |         20        0.62       42.49
                Indonesia |         20        0.62       43.11
                     Iran |         20        0.62       43.73
                     Iraq |         19        0.59       44.32
                  Ireland |         20        0.62       44.94
                   Israel |         20        0.62       45.56
                    Italy |         20        0.62       46.18
                  Jamaica |         20        0.62       46.80
                    Japan |         20        0.62       47.42
                   Jordan |         20        0.62       48.04
               Kazakhstan |         16        0.50       48.54
                    Kenya |         20        0.62       49.16
                   Kuwait |         20        0.62       49.78
               Kyrgyzstan |         16        0.50       50.28 -> drop
                     Laos |         20        0.62       50.90
                   Latvia |         18        0.56       51.46
                  Lebanon |         20        0.62       52.08
                  Lesotho |         20        0.62       52.70
                  Liberia |         20        0.62       53.32
                    Libya |         20        0.62       53.94
                Lithuania |         18        0.56       54.50
               Luxembourg |         20        0.62       55.12
                Macao SAR |         20        0.62       55.74
               Madagascar |         20        0.62       56.36
                   Malawi |         20        0.62       56.98
                 Malaysia |         20        0.62       57.60
                 Maldives |         20        0.62       58.22
                     Mali |         20        0.62       58.85
                    Malta |         20        0.62       59.47
               Mauritania |         19        0.59       60.06
                Mauritius |         20        0.62       60.68
                   Mexico |         20        0.62       61.30
                  Moldova |         15        0.47       61.76 -> drop
                 Mongolia |         19        0.59       62.35
               Montenegro |         11        0.34       62.69 -> drop
                  Morocco |         20        0.62       63.31
               Mozambique |         20        0.62       63.94
                  Myanmar |         20        0.62       64.56
                  Namibia |         20        0.62       65.18
                    Nepal |         20        0.62       65.80
              Netherlands |         20        0.62       66.42
              New Zealand |         20        0.62       67.04
                Nicaragua |         20        0.62       67.66
                    Niger |         20        0.62       68.28
                  Nigeria |         20        0.62       68.90
                   Norway |         20        0.62       69.52
                     Oman |         20        0.62       70.14
                 Pakistan |         20        0.62       70.76
                   Panama |         20        0.62       71.38
         Papua New Guinea |         20        0.62       72.00
                 Paraguay |         20        0.62       72.63
                     Peru |         20        0.62       73.25
              Philippines |         20        0.62       73.87
                   Poland |         20        0.62       74.49
                 Portugal |         20        0.62       75.11
                    Qatar |         20        0.62       75.73
                  Romania |         20        0.62       76.35
                   Russia |         20        0.47       76.82
                   Rwanda |         20        0.62       77.44
                    Samoa |         20        0.62       78.06
               San Marino |         13        0.40       78.46 -> drop
    Sao Tome and Principe |         19        0.59       79.05
             Saudi Arabia |         20        0.62       79.67
                  Senegal |         20        0.62       80.29
                   Serbia |         13        0.40       80.70
               Seychelles |         20        0.62       81.32
             Sierra Leone |         20        0.62       81.94
                Singapore |         20        0.62       82.56
                 Slovakia |         17        0.53       83.09
                 Slovenia |         19        0.59       83.67
                  Somalia |          1        0.03       83.71 -> drop
             South Africa |         20        0.62       84.33
              South Korea |         20        0.62       84.95
                    Spain |         20        0.62       85.57
                Sri Lanka |         20        0.62       86.19
                 Suriname |         20        0.62       86.81
                   Sweden |         20        0.62       87.43
              Switzerland |         20        0.62       88.05
                    Syria |         20        0.62       88.67
           TFYR Macedonia |         16        0.50       89.17
               Tajikistan |         18        0.56       89.73
                 Tanzania |         20        0.62       90.35
                 Thailand |         20        0.62       90.97
                     Togo |         20        0.62       91.59
      Trinidad and Tobago |         20        0.62       92.21
                  Tunisia |         20        0.62       92.83
                   Turkey |         20        0.62       93.45
             Turkmenistan |          8        0.25       93.70 -> drop
                       UK |         20        0.62       94.32
                      USA |         20        0.62       94.94
                   Uganda |         20        0.62       95.56
                  Ukraine |         17        0.53       96.09
                  Uruguay |         20        0.62       96.71
               Uzbekistan |          6        0.19       96.90 -> drop
                  Vanuatu |         20        0.62       97.52
                Venezuela |         20        0.62       98.14
                 Viet Nam |         20        0.62       98.76
                    Yemen |         20        0.62       99.38
                   Zambia |         20        0.62      100.00
--------------------------+-----------------------------------
                    Total |      3,222      100.00



*/

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



* We save data
save "${output}/data-stata/eora/06-gross_output_country-industry_v2.dta", replace
