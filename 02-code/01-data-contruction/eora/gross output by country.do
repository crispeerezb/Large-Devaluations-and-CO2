/*
********************************************************
THIS CODE CREATE A DATA SET WITH GROSS OUTPUT BY COUNTRY
********************************************************
*/


*** set working dictory ***
if "`c(username)'" == "ezequiel.garcia" {
  global egdir "change where you clone the repository"
}

else if "`c(username)'" == "crist" {
	global egdir "C:\Users\crist\Dropbox Dropbox\Cristóbal Pérez Barraza\A-Large Devaluations and CO2\"
}

cd "$egdir"


/*
Observations:

1) Note that the data used here isn't in the GitHub repository since this data is too big

*/