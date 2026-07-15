/********************************************************************************************
FILE: 03_analysis.do

PURPOSE:
      Produce descriptive statistics and regression analysis for the
      productivity-formality study of women-led agro-processing enterprises.

INPUT:
      data/processed/ahies_2022_2024_pooled.dta

OUTPUT:
      Console output (tables and regression results)

AUTHOR:
      Jessica Naa L. France
********************************************************************************************/

*--------------------------------------------------------------
* INSTALL REQUIRED USER-WRITTEN PACKAGES (FIRST RUN ONLY)
*--------------------------------------------------------------

capture which esttab
if _rc ssc install estout

capture which coefplot
if _rc ssc install coefplot

clear all
set more off

*------------------------------------------------------------*
* Project directory
*------------------------------------------------------------*

cd "$project"

*------------------------------------------------------------*
* Load analytical dataset
*------------------------------------------------------------*

use "data/processed/ahies_2022_2024_pooled.dta", clear


/********************************************************************************************
                            DATA VALIDATION
********************************************************************************************/

display "--------------------------------------------"
display "DATA SUMMARY"
display "--------------------------------------------"

describe

summarize

tab year

tab female

tab agro

tab formal


*--------------------------------------------------------------
* CREATE OUTPUT FOLDERS
*--------------------------------------------------------------

global output "$project/output"
global tables "$output/tables"
global figures "$output/figures"

capture mkdir "$output"
capture mkdir "$tables"
capture mkdir "$figures"

/********************************************************************************************
                     DESCRIPTIVE STATISTICS (TRAP DIAGNOSTIC)
********************************************************************************************/

display "--------------------------------------------"
display "DESCRIPTIVE STATISTICS"
display "--------------------------------------------"

estpost summarize hours_nonfarm age educ

esttab using ///
"$tables/descriptive_statistics.rtf", ///
replace ///
cells("count mean sd min max") ///
label ///
title("Descriptive Statistics")

* Mean hours by agro-processing and formality
preserve

collapse (mean) hours_nonfarm, by(agro formal)

export excel using ///
"$tables/agro_formality_means.xlsx", ///
replace firstrow(variables)

restore

* Mean hours by agro-processing and gender
preserve

collapse (mean) hours_nonfarm, by(agro female)

export excel using ///
"$tables/agro_gender_means.xlsx", ///
replace firstrow(variables)

restore

* Mean hours by gender and formality
preserve

collapse (mean) hours_nonfarm, by(female formal)

export excel using ///
"$tables/formal_gender_means.xlsx", ///
replace firstrow(variables)

restore

table female formal, c(mean hours_nonfarm n hours_nonfarm)


/********************************************************************************************
                     PERSISTENCE OVER TIME
********************************************************************************************/

display "--------------------------------------------"
display "PERSISTENCE OVER TIME"
display "--------------------------------------------"

preserve

collapse (mean) hours_nonfarm, by(year agro formal)

export excel using ///
"$tables/persistence_over_time.xlsx", ///
replace firstrow(variables)

restore


*--------------------------------------------------------------
* FIGURE 1
*--------------------------------------------------------------
preserve

collapse (mean) hours_nonfarm, by(agro formal)

graph bar hours_nonfarm, ///
over(formal) ///
over(agro) ///
ytitle("Average Weekly Hours")

graph export ///
"$figures/enterprise_hours_by_formality.png", ///
replace

restore


*--------------------------------------------------------------
* FIGURE 2
*--------------------------------------------------------------
preserve

collapse (mean) hours_nonfarm, by(female)

graph bar hours_nonfarm, ///
over(female)

graph export ///
"$figures/enterprise_hours_by_gender.png", ///
replace

restore


*--------------------------------------------------------------
* FIGURE 3
*--------------------------------------------------------------
preserve

collapse (mean) hours_nonfarm, by(year agro)

twoway ///
(line hours_nonfarm year if agro==0) ///
(line hours_nonfarm year if agro==1), ///
legend(order(1 "Non-agro" 2 "Agro"))

graph export ///
"$figures/enterprise_hours_over_time.png", ///
replace

restore


/********************************************************************************************
                    REGRESSION ANALYSIS
********************************************************************************************/

display "--------------------------------------------"
display "BASELINE MODEL"
display "--------------------------------------------"

eststo clear

reg hours_nonfarm ///
i.agro##i.formal ///
i.female ///
age ///
educ ///
i.year, robust

eststo Baseline


display "--------------------------------------------"
display "GENDER HETEROGENEITY"
display "--------------------------------------------"

reg hours_nonfarm ///
i.agro##i.formal##i.female ///
age ///
educ ///
i.year, robust

eststo Gender


*--------------------------------------------------------------
* EXPORT REGRESSION TABLE
*--------------------------------------------------------------
esttab Baseline Gender using ///
"o$tables/pooled_ols_results.rtf", ///
replace ///
label ///
b(3) ///
se(3) ///
star(* 0.10 ** 0.05 *** 0.01) ///
title("Pooled OLS Estimates")


*--------------------------------------------------------------
* COEFFICIENT PLOT
*--------------------------------------------------------------
coefplot Baseline Gender, ///
drop(_cons *.year age educ) ///
vertical ///
xline(0)

graph export ///
"$figures/regression_coefficients.png", ///
replace

/********************************************************************************
                    OPTIONAL ROBUSTNESS CHECKS
********************************************************************************/

display "--------------------------------------------"
display "ROBUSTNESS: FEMALES ONLY"
display "--------------------------------------------"

reg hours_nonfarm ///
    i.agro##i.formal ///
    age ///
    educ ///
    i.year ///
    if female==1, robust


display "--------------------------------------------"
display "ROBUSTNESS: MALES ONLY"
display "--------------------------------------------"

reg hours_nonfarm ///
    i.agro##i.formal ///
    age ///
    educ ///
    i.year ///
    if female==0, robust


display "--------------------------------------------"
display "ANALYSIS COMPLETE"
display "--------------------------------------------"

/********************************************************************************************
   END OF FILE
********************************************************************************************/
