/********************************************************************************************
FILE: 02_variable_construction.do

PURPOSE:
      Construct analytical variables, pool the cleaned datasets,
      and prepare the final analytical file.

INPUT:
      data/processed/
          2022_ahies_clean.dta
          2023_ahies_clean.dta
          2024_ahies_clean.dta

OUTPUT:
      data/processed/ahies_2022_2024_pooled.dta

AUTHOR:
      Jessica Naa L. France
********************************************************************************************/

clear all
set more off

g*------------------------------------------------------------*
* Project directories
*------------------------------------------------------------*

cd "$project"

global clean "$project/data/clean"
global processed "$project/data/processed"
capture mkdir "$processed"

*------------------------------------------------------------*
* 1. Ensure survey weights are numeric
*------------------------------------------------------------*

foreach y in 2022 2023 2024 {

    use "$clean/`y'_ahies_clean.dta", clear

    capture destring pop_weight, replace force
    capture destring hh_weight, replace force

    save "$clean/`y'_ahies_clean.dta", replace
}

*------------------------------------------------------------*
* 2. Append all survey years
*------------------------------------------------------------*

use "$clean/2022_ahies_clean.dta", clear

append using "$clean/2023_ahies_clean.dta"

append using "$clean/2024_ahies_clean.dta"

save "$processed/ahies_2022_2024_pooled.dta", replace

*------------------------------------------------------------*
* 3. Variable labels
*------------------------------------------------------------*

label variable hours_nonfarm ///
    "Weekly hours worked in non-farm enterprise"

label variable agro ///
    "Agro-processing enterprise"

label variable formal ///
    "Formal enterprise"

label variable female ///
    "Female respondent"

label variable age ///
    "Age"

label variable educ ///
    "Education level"

label variable year ///
    "Survey year"

*------------------------------------------------------------*
* 4. Order variables
*------------------------------------------------------------*

order hhid year ///
      female age educ ///
      agro formal ///
      hours_nonfarm

sort year hhid

compress

*------------------------------------------------------------*
* 5. Save pooled analytical dataset
*------------------------------------------------------------*

save "$processed/ahies_2022_2024_pooled.dta", replace

display "------------------------------------------------------"
display "Pooled analytical dataset created successfully."
display "------------------------------------------------------"

describe

tab year
