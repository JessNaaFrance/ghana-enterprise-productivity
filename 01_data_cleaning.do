/********************************************************************************************
PROJECT: Women-Led Agro-Processing Enterprises in Northern Ghana (Ghana AHIES Multi-Year Enterprise Analysis)
FILE: 01_data_cleaning.do

PURPOSE:
    Import, harmonize, and clean AHIES survey data for 2022-2024.

OUTPUT:
    data/clean/2022_ahies_clean.dta
    data/clean/2023_ahies_clean.dta
    data/clean/2024_ahies_clean.dta

AUTHOR:
    Jessica Naa L. France
********************************************************************************************/

clear all
set more off

*--------------------------------------------------------------
* Project directories
*--------------------------------------------------------------

global project   "PATH_TO_PROJECT_FOLDER"

global raw   "$project/data/raw"
global clean "$project/data/clean"

capture mkdir "$clean"

*--------------------------------------------------------------
* Program to clean one survey year
*--------------------------------------------------------------

capture program drop build_ahies
program define build_ahies

args year filename filetype

di ""
di "======================================"
di "Cleaning AHIES `year'"
di "======================================"

*----------------------------------------------------------
* Loading data
*----------------------------------------------------------

if "`filetype'"=="dta" {
 use "$raw/`filename'", clear
}

if "`filetype'"=="csv" {

 import delimited "$raw/`filename'", clear stringcols(_all)

 foreach v in ///
 s1aq4y ///
 s2aq4 ///
 s4aq13a s4aq13b s4aq13c s4aq13d s4aq13e s4aq13f s4aq13g ///
 s4aq41a2 s4aq41a3 ///
 s4bq3a2 s4bq3a3 ///
 s4dq4a2 s4dq4a3 ///
 s4gq4a2 s4gq4a3 ///
 s4aq42 {

 capture destring `v', replace ignore(" ")
 }
}

*----------------------------------------------------------
* Harmonizing sex
*----------------------------------------------------------

capture confirm string variable s1aq1

if !_rc {

 replace s1aq1 = trim(s1aq1)

 gen sex = .

 replace sex = 1 if s1aq1=="Male"
 replace sex = 2 if s1aq1=="Female"

 }

else {

gen sex = s1aq1

}

label define sexlbl 1 "Male" 2 "Female", replace
label values sex sexlbl

*----------------------------------------------------------
* Harmonizing non-farm enterprise indicator
*----------------------------------------------------------

capture confirm string variable s4aq11

if !_rc {

replace s4aq11 = trim(s4aq11)

gen s4aq11_num = .

replace s4aq11_num = 1 if s4aq11=="Yes"
replace s4aq11_num = 0 if s4aq11=="No"

drop s4aq11
rename s4aq11_num s4aq11

}

label define enterprise 0 "No" 1 "Yes", replace
label values s4aq11 enterprise

*----------------------------------------------------------
* Harmonizing employer type
*----------------------------------------------------------

capture confirm string variable s4aq42

if !_rc {

replace s4aq42 = trim(upper(s4aq42))

gen s4aq42_num = .

replace s4aq42_num = 1 if inlist(s4aq42,"PUBLIC","GOVERNMENT","1")

replace s4aq42_num = 2 if inlist(s4aq42,"PARASTATAL","SEMI-PUBLIC","2")

replace s4aq42_num = 3 if inlist(s4aq42,"PRIVATE FORMAL","3")

replace s4aq42_num = 4 if strpos(s4aq42,"PRIVATE INFORMAL")>0

replace s4aq42_num = 5 if strpos(s4aq42,"NGO")>0 | strpos(s4aq42,"CSO")>0

drop s4aq42
rename s4aq42_num s4aq42

}

label define employer ///
1 "Public" ///
2 "Parastatal" ///
3 "Private formal" ///
4 "Private informal" ///
5 "NGO/CSO", replace

label values s4aq42 employer

*----------------------------------------------------------
* Survey year
*----------------------------------------------------------

gen year = `year'

label var year "Survey year"

*----------------------------------------------------------
* Restricting to adults
*----------------------------------------------------------

keep if s1aq4y >=18

*----------------------------------------------------------
* Formalization indicator
*----------------------------------------------------------

gen formal = (s4aq42 == 3)

label define formal_lbl 0 "Informal" 1 "Formal", replace
label values formal formal_lbl
label var formal "Formal enterprise"
	
*----------------------------------------------------------
* Female indicator
*----------------------------------------------------------

gen female = (sex==2)

label var female "Female respondent"

*----------------------------------------------------------
* Reconstructing industry code
*----------------------------------------------------------

gen industry = s4aq41a3

replace industry = s4bq3a3 if missing(industry)
replace industry = s4dq4a3 if missing(industry)
replace industry = s4gq4a3 if missing(industry)

replace industry = s4aq41a2 if missing(industry)
replace industry = s4bq3a2 if missing(industry)
replace industry = s4dq4a2 if missing(industry)
replace industry = s4gq4a2 if missing(industry)

gen str12 indstr = string(industry,"%12.0g")

*----------------------------------------------------------
* Age and education
*----------------------------------------------------------

gen age = s1aq4y

label var age "Age of respondent"
        
gen educ = s2aq4

label var educ "Education level"

label values agro agro_lbl

*----------------------------------------------------------
* Agro-processing indicator
*----------------------------------------------------------

gen agro = inlist(substr(indstr,1,2),"10","11","12")

label define agro_lbl ///
0 "Non-agro" ///
1 "Agro-processing", replace

label values agro agro_lbl

*----------------------------------------------------------
* Weekly enterprise labour
*----------------------------------------------------------

egen hours_nonfarm = rowtotal(s4aq13a s4aq13b s4aq13c s4aq13d s4aq13e s4aq13f s4aq13g)
replace hours_nonfarm = 0 if s4aq11==0

label var hours_nonfarm "Weekly hours in non-farm enterprise"

*----------------------------------------------------------
* Enterprise workers only
*----------------------------------------------------------

keep if hours_nonfarm>0

*----------------------------------------------------------
* Household ID
*----------------------------------------------------------

capture confirm numeric variable hhid

if !_rc {

tostring hhid, replace

}

*----------------------------------------------------------
* Converting weights if necessary
*----------------------------------------------------------

capture destring pop_weight hh_weight, replace force

*----------------------------------------------------------
* Saving cleaned file
*----------------------------------------------------------

compress

save "$clean/`year'_ahies_clean.dta", replace

di "`year' cleaned successfully."

end

*--------------------------------------------------------------
* Running cleaning
*--------------------------------------------------------------

build_ahies ///
2022 ///
    "2022 AHIES Q1-Q4_Rev_20250827.dta" ///
    dta

build_ahies ///
    2023 ///
    "2023 AHIES Q1-Q4_Rev_20250827.dta" ///
    dta

build_ahies ///
    2024 ///
    "2024 AHIES Q1-Q4_20250827.csv" ///
    csv

display ""
display "-------------------------------------"
display "DATA CLEANING COMPLETE"
display "-------------------------------------"
