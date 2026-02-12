# ============================================
# NO2 COVID Sheffield (Devonshire Green) Project
# Used for both IJC437 & IJC445
# 01 Data Cleaning Script
# ============================================

# Load libraries==============================
library(tidyverse)
library(lubridate)



# Import raw data (skip metadata rows)==============================
raw_2018 <- read_csv(
  "data_raw/AirQualityDataHourly_2018.csv",
  skip = 10
)

raw_2020 <- read_csv(
  "data_raw/AirQualityDataHourly_2020.csv",
  skip = 10
)

raw_2023 <- read_csv(
  "data_raw/AirQualityDataHourly_2023.csv",
  skip = 10
)


# Diagnose datetime parsing issues (2018 data)
bad_datetime_2018 <- raw_2018 %>%
  
  # Select relevant columns required to construct datetime
  select(Date, Time, `Nitrogen dioxide`) %>%
  
  # Standardise column names for consistency
  rename(date = Date, time = Time, NO2 = `Nitrogen dioxide`) %>%
  
  # Attempt to create datetime object to identify parsing failures
  mutate(
    datetime_test = suppressWarnings(ymd_hms(paste(date, time)))
  ) %>%
  
  # Filter records where datetime parsing failed
  filter(is.na(datetime_test))

# Inspect records with invalid or non-parsable datetime values
bad_datetime_2018


# Data cleaning: 2018==============================
clean_2018 <- raw_2018 %>%
  # Select only relevant variables for analysis
  select(Date, Time, `Nitrogen dioxide`) %>%
  
  # Rename variables for consistency and readability
  rename(
    date = Date, 
    time = Time, 
    NO2 = `Nitrogen dioxide`
    ) %>%
  
  # Exclude non-data footer row
  filter(date != "End")%>%  
  
  # Create datetime object and extract temporal features
  mutate(
    NO2 = na_if(NO2, "No data"),
    NO2 = as.numeric(NO2),
    datetime = ymd_hms(paste(date, time)),
    year = 2018,
    month = month(datetime, label = TRUE)
  ) %>%
  
  # Remove records with missing NO2 values or invalid timestamps
  filter(!is.na(NO2), !is.na(datetime))



# Export cleaned dataset (.csv)==============================
write_csv(clean_2018, "data_clean/no2_2018_clean.csv")





# Diagnose datetime parsing issues (2020 data)
bad_datetime_2020 <- raw_2020 %>%
  
  # Select relevant columns required to construct datetime
  select(Date, Time, `Nitrogen dioxide`) %>%
  
  # Standardise column names for consistency
  rename(date = Date, time = Time, NO2 = `Nitrogen dioxide`) %>%
  
  # Attempt to create datetime object to identify parsing failures
  mutate(
    datetime_test = suppressWarnings(ymd_hms(paste(date, time)))
  ) %>%
  
  # Filter records where datetime parsing failed
  filter(is.na(datetime_test))

# Inspect records with invalid or non-parsable datetime values
bad_datetime_2020



# Data cleaning: 2020==============================
clean_2020 <- raw_2020 %>%
  
  # Select only relevant variables for analysis
  select(Date, Time, `Nitrogen dioxide`) %>%
  
  # Rename variables for consistency and readability
  rename(
    date = Date, 
    time = Time, 
    NO2 = `Nitrogen dioxide`
    ) %>%
 
  # Exclude non-data footer row
  filter(date != "End")%>%  
  
  # Create datetime object and extract temporal features
  mutate(
    NO2 = na_if(NO2, "No data"),
    NO2 = as.numeric(NO2),
    datetime = ymd_hms(paste(date, time)),
    year = 2020,
    month = month(datetime, label = TRUE)
  ) %>%
  
  # Remove records with missing NO2 values or invalid timestamps
  filter(!is.na(NO2), !is.na(datetime))


# Export cleaned dataset (.csv)==============================
write_csv(clean_2020, "data_clean/no2_2020_clean.csv")





# Diagnose datetime parsing issues (2018 data)
bad_datetime_2023 <- raw_2023 %>%
  
  # Select relevant columns required to construct datetime
  select(Date, Time, `Nitrogen dioxide`) %>%
  
  # Standardise column names for consistency
  rename(date = Date, time = Time, NO2 = `Nitrogen dioxide`) %>%
  
  # Attempt to create datetime object to identify parsing failures
  mutate(
    datetime_test = suppressWarnings(ymd_hms(paste(date, time)))
  ) %>%
  
  # Filter records where datetime parsing failed
  filter(is.na(datetime_test))

# Inspect records with invalid or non-parsable datetime values
bad_datetime_2023


# Data cleaning: 2023==============================
clean_2023 <- raw_2023 %>%
  # Select only relevant variables for analysis
  select(Date, Time, `Nitrogen dioxide`) %>%
  
  # Rename variables for consistency and readability
  rename(
    date = Date,
    time = Time,
    NO2 = `Nitrogen dioxide`
  ) %>%
  
  # Exclude non-data footer row
  filter(date != "End")%>%  
  
  # Create datetime object and extract temporal features
  mutate(
    NO2 = na_if(NO2, "No data"),
    NO2 = as.numeric(NO2),
    datetime = ymd_hms(paste(date, time)),
    year = 2023,
    month = month(datetime, label = TRUE)
  ) %>%
  
  # Remove records with missing NO2 values or invalid timestamps
  filter(!is.na(NO2), !is.na(datetime))


# Export cleaned dataset (.csv)==============================
write_csv(clean_2023, "data_clean/no2_2023_clean.csv")
