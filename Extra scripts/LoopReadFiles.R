#install.packages("purrr")
#install.packages("fs)
library(purrr)
library(fs)
library(tidyverse)

# Get vector of character gauge_id's from data
gauge_ids <- camels_all$gauge_id

# Change to your directory, wherever you've saved the CAMELS data
# Should have a root directory of 'usgs_streamflow'
dir <- "D:/Gannon Research/Timeseries Data/basin_dataset_public_v1p2/usgs_streamflow"

# Get a list of all text files in the directory and its subdirectories
all_files <- list.files(path = dir, pattern = "\\.txt$", full.names = TRUE, recursive = TRUE)

#Add header column names
column_names <- c("gauge_id", "year", "month", "day", "q", "QCflag")

# Initialize an empty list to store the data frames
data_list <- list()

# Loop through the gauge IDs
for (id in gauge_ids) {
  # Create the file name pattern, each file ends with '_streamflow_qc
  pattern <- paste0(id, "_streamflow_qc.txt$")
  
  # Find the file that matches the current gauge ID
  file <- grep(pattern, all_files, value = TRUE)
  
  # Check if the file exists
  if (length(file) > 0) {
    # Read the file and store it in the list
    data_list[[id]] <- read.table(file, header = FALSE, col.names = column_names, sep = "")
  }
}

# Bind all the data frames in the list
DailyQ <- bind_rows(data_list)

#Filter out days where flow info is missing (QCflag = M)
DailyQ <- DailyQ |> 
  filter(QCflag != "M") |>
  #filter(QCflag != "A:e") |> 
  mutate(date = dmy(paste(day, month, year))) |> 
  dplyr:: select(-year, -month, -day)

#Filter out days by applicable water year

DailyQ$date <- as.Date(DailyQ$date)

DailyQ <- DailyQ %>%
  filter(date >= as.Date("1989-10-01") & date <= as.Date("2009-09-30"))

# Might want to write out this big CSV here!

DailyQ$gauge_id <- as.character(DailyQ$gauge_id) 
DailyQ$gauge_id <- paste0("0", DailyQ$gauge_id)

## Join USGS Area2 data

USGS = st_read("C:\\Users\\Logan\\Desktop\\College\\Coursework\\Junior Year\\Research Project\\data\\Gages_physio shp")

USGS1 = select(USGS, SOURCE_FEA, AREA)

DailyQ = left_join(DailyQ, USGS1, by=c("gauge_id"="SOURCE_FEA"))

## Convert to Qmm_day

DailyQ <- DailyQ |> 
  mutate(Qmm_day = 2.447 * q / AREA) |>
  dplyr:: select(-geometry)
