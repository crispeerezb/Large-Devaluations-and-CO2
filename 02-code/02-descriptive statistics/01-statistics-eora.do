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


*** load data set ***
use "${output}\data-stata\eora\02-co2-emissions-scope-1-country-industry.dta", clear

*** collapse data to country level ***
collapse (sum) scope_1_A grossoutput, by(country country_code year)

*** gen rates variable ***
gen rate_scope_1 = scope_1_A/grossoutput

*** graph ***
twoway (line rate_scope_1 year if country_code == "COL"), xline(2014) title("COLOMBIA")
twoway (line rate_scope_1 year if country_code == "MEX"), xline(1995) title("MEXICO")
twoway (line rate_scope_1 year if country_code == "RUS"), xline(1998) title("RUSSIA")
twoway (line rate_scope_1 year if country_code == "FIN"), xline(1993) title("FINLAND")
twoway (line rate_scope_1 year if country_code == "ISL"), xline(2014) title("ISLAND")
twoway (line rate_scope_1 year if country_code == "MYS"), xline(1997) title("MALAYSIA")
twoway (line rate_scope_1 year if country_code == "IDN"), xline(1998) title("INDONESIA")
twoway (line rate_scope_1 year if country_code == "THA"), xline(1998) title("THAILAND")
twoway (line rate_scope_1 year if country_code == "KOR"), xline(1998) title("KOREA")
twoway (line rate_scope_1 year if country_code == "TUR"), xline(1994) title("TURKEY")
twoway (line rate_scope_1 year if country_code == "TUR"), xline(2001) title("TURKEY")
twoway (line rate_scope_1 year if country_code == "BRA"), xline(1999) title("BRASIL")
twoway (line rate_scope_1 year if country_code == "IND"), xline(1991) title("INDIA")



	   
	   
	 
	   
	   
	   



