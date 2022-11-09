# R Studio Version 1.4.1717

# Date: 08/03/2022
# Contact: nrdd.admin@noaa.gov or ishrat.jabin@noaa.gov for questions/concerns

# This R code will demonstrate how you may clean, filter, or manipulate NRDD data


# READ ME:
# 1. Ensure that all libraries are installed/loaded before running code. 
#    Different versions of R may not be compatible with the R packages.
# 2. Export file from QueryBuilder in HTML Table Format
# 3. Load HTML Table file. A pop-up display will ask you to
#    select a file from your directory.

###############################################################################
# Libraries ---------------------------------------------------------------

library(xml2)
library(rvest)
library(janitor)
library(readxl)
library(writexl)
library(dplyr)
library(lubridate)

# Select HTML Data File, then load table ---------------------------------------

htm_tbl <- read_html(file.choose()) #via HTML
Projects <- as.data.frame(html_table(htm_tbl, fill=TRUE)) #via HTML
Projects <- Projects %>% clean_names()

# To manipulate dates ----------------------------------------------------------

# If your data has dates, mutate (reformat) the dates using the following code
# so that they are read correctly by the program.

Projects <- Projects %>%
  mutate(last_record_update = mdy_hms(last_record_update)) %>%
  mutate(planned_project_start = mdy(planned_project_start)) %>%
  mutate(planned_project_end = mdy(planned_project_end)) %>%
  mutate(actual_project_start = mdy(actual_project_start)) %>%
  mutate(actual_project_end = mdy(actual_project_end))

# Filter Projects by Date ------------------------------------------------------
d1 <- ymd("2020-10-01") # October 1, 2020
d2 <- ymd("2021-09-30") # September 30, 2021
int <- interval(d1, d2)

Projects <- Projects %>%
  filter(planned_project_start%within%int | actual_project_start%within%int )

# To concatenate multiple entries by delimiter----------------------------------

# Load an NRDD HTM file from the External Partners/NOAA Partners Table
# Some projects have multiple partners, therefore the table will have multiple
# rows with the same projects (but with different partners).
# To merge the partner information into a single cell entry run the following
# code. 

Projects <- Projects %>%
  group_by(nrdd_project_id, project_title, project_description, .drop = FALSE) %>% 
  summarise(noaa_partner = paste(noaa_partner, collapse="; "))

