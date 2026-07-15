/********************************************************************************************
PROJECT:
Women-Led Agro-Processing Enterprises in Northern Ghana

AUTHOR:
Jessica Naa L. France

PURPOSE:
Master script for reproducing the analytical workflow used in the
Harvard Kennedy School Second Year Policy Analysis (SYPA).

DESCRIPTION:
This script executes the complete workflow in sequence:

    1. Data cleaning and harmonization
    2. Variable construction
    3. Statistical analysis

Raw AHIES data are confidential and are therefore not included in this repository.

********************************************************************************************/

clear all
set more off
version 16

*--------------------------------------------------------------
* SET PROJECT DIRECTORY
*--------------------------------------------------------------

* Replace the path below with the location where you saved
* the replication files and the AHIES datasets.

* Example:
* global project "C:/Users/YourName/Documents/ghana-enterprise-productivity"

global project "PATH_TO_PROJECT_FOLDER"

cd "$project"

*--------------------------------------------------------------
* RUN REPLICATION FILES
*--------------------------------------------------------------

do "01_data_cleaning.do"

do "02_variable_construction.do"

do "03_analysis.do"

display "Replication completed successfully."

/********************************************************************************************
END OF FILE
********************************************************************************************/
