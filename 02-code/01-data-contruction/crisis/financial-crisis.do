/*
**********************************************
THIS CODE CREATE A TABLE WITH FINANCIAL CRISIS
**********************************************
*/


*** set working dictory ***
if "`c(username)'" == "ezequiel.garcia" {
  global egdir "change where you clone the repository"
}

else if "`c(username)'" == "crist" {
	global egdir "C:\Users\crist\OneDrive\Documentos\GitHub\Large-Devaluations-and-CO2\"
}

cd "$egdir"

*** load data set ***
clear
import excel "01-raw-data\IMF Crisis Data\IMF Financial crisis episodes database 2008.xls",firstrow sheet("Crisis dates database 1970-2007") cellrange(A3)

drop in -1

*******************************************************
* 1) first create aux data set with countries and years
********************************************************

* create a data set with years
preserve
clear
set obs 38
gen year = 1969
replace year = year + _n
save "03-temp\years_financial_crisis.dta", replace
restore

* create a data set with countries
keep Country
duplicates drop Country, force

* create panel
cross using "03-temp\years_financial_crisis.dta"
sort Country year
***************************************************
* 2) second create aux data set with type of crisis
***************************************************

* data set with dummy for Sistematic Banking Crisis
preserve
clear
import excel "01-raw-data\IMF Crisis Data\IMF Financial crisis episodes database 2008.xls",firstrow sheet("Crisis dates database 1970-2007") cellrange(A3)
keep Country SystemicBankingCrisisstartin
drop if SystemicBankingCrisisstartin ==.
gen sist_banking_crisis = 1
rename SystemicBankingCrisisstartin year
save "03-temp\SystemicBankingCrisis.dta", replace
restore

* data set with dummy for Currency Crisis
preserve
clear
import excel "01-raw-data\IMF Crisis Data\IMF Financial crisis episodes database 2008.xls",firstrow sheet("Crisis dates database 1970-2007") cellrange(A3)
keep Country CurrencyCrisisstartingdate
drop if CurrencyCrisisstartingdate ==.
gen currancy_crisis = 1
rename CurrencyCrisisstartingdate year
save "03-temp\CurrancyCrisis.dta", replace
restore

* data set with dummy for Debt Crisis
preserve
clear
import excel "01-raw-data\IMF Crisis Data\IMF Financial crisis episodes database 2008.xls",firstrow sheet("Crisis dates database 1970-2007") cellrange(A3)
keep Country DebtCrisisstartingdate
drop if DebtCrisisstartingdate ==.
gen debt_crisis = 1
rename DebtCrisisstartingdate year
save "03-temp\DebtCrisis.dta", replace
restore

**********************************
* 2) panel with dummies for crisis
**********************************
merge m:m Country year using "03-temp\SystemicBankingCrisis.dta"
drop _merge

merge m:m Country year using "03-temp\CurrancyCrisis.dta"
drop _merge

merge m:m Country year using "03-temp\DebtCrisis.dta"
drop _merge

gen crisis = (sist_banking_crisis == 1) | (currancy_crisis == 1) | (debt_crisis == 1)

save "04-output\data-stata\financial-crisis\financial_crisis_by_country-year.dta"
