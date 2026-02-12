# ============================================
# NO2 COVID Sheffield (Devonshire Green) Project
# Used for both IJC437 & IJC445
# 02_analysis.R
# ============================================

# Load libraries==============================
library(tidyverse)
library(lubridate)


# Create output folders=========
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables",  recursive = TRUE, showWarnings = FALSE)

# Read cleaned hourly NO2 data for each study year=====
d2018 <- read_csv("data_clean/no2_2018_clean.csv")
d2020 <- read_csv("data_clean/no2_2020_clean.csv")
d2023 <- read_csv("data_clean/no2_2023_clean.csv")

# Combine all years into a single dataset for analysis=====
data_all <- bind_rows(d2018, d2020, d2023)


# Inspect the structure of the combined dataset============
glimpse(data_all)


# Identify records where NO2 values cannot be converted to numeric
bad_no2 <- data_all %>%
  
  # Keep rows where NO2 is not missing
  filter(!is.na(NO2)) %>%
  
  # Attempt to convert NO2 to numeric to detect non-numeric entries
  mutate(NO2_num = suppressWarnings(as.numeric(NO2))) %>%
  
  # Filter rows where numeric conversion failed
  filter(is.na(NO2_num)) %>%
  
  # Select key variables for inspection
  select(year, datetime, NO2) %>%
  
  # Display only the first 20 problematic records
  head(20)

# View problematic NO2 records
bad_no2



# Safety check: keep only valid NO2 and datetime
data_all <- data_all %>%
  filter(!is.na(NO2), !is.na(datetime))




# Safety check: remove records with missing or invalid datetime
data_all <- data_all %>%
  filter(!is.na(datetime))


# Check datetime format for time-based analysis (POSIXct)
str(data_all$datetime)






# Summary statistics of NO2 by year
year_summary <- data_all %>%
  
  # Group observations by year
  group_by(year) %>%
  
  # Compute key descriptive statistics for each year
  summarise(
    
    # Number of valid hourly observations
    n = n(),
    
    # Mean NO2 concentration
    mean_NO2 = mean(NO2, na.rm = TRUE),
    
    # Median NO2 concentration
    median_NO2 = median(NO2, na.rm = TRUE),
    
    # Standard deviation of NO2
    sd_NO2 = sd(NO2, na.rm = TRUE),
    
    # 95th percentile (high-end pollution levels)
    p95_NO2 = quantile(NO2, 0.95, na.rm = TRUE),
    
    # Tell R to remove grouping after summarisation
    .groups = "drop"
  )
# Display summary table
year_summary

# Create folder for tables
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

# Export summary statistics(.)
readr::write_csv(year_summary, "outputs/tables/year_summary.csv")




# Figure 1: Distribution of NO2 by year (RQ1) ============
p_box <- ggplot(data_all, aes(x = factor(year), y = NO2)) +
  geom_boxplot(outlier.alpha = 0.3) +
  labs(
    title = "Distribution of hourly NO2 by year (Devonshire Green)",
    x = "Year",
    y = "Hourly NO2 (µg/m³)"
  )

# Display plot in RStudio
p_box

# Save plot to outputs folder
ggsave("outputs/figures/figure1_boxplot_year.png", 
       p_box, width = 7, 
       height = 5, 
       dpi = 300
       )




# Figure 2: Monthly mean NO2 by year (RQ2)
monthly <- data_all %>%
  mutate(month_num = month(datetime)) %>%
  group_by(year, month_num) %>%
  summarise(mean_NO2 = mean(NO2, na.rm = TRUE), .groups = "drop") %>%
  mutate(month = factor(month_num, levels = 1:12, labels = month.abb))

p_month <- ggplot(monthly, aes(x = month, y = mean_NO2, color = factor(year), group = year)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Monthly mean NO2 by year (Devonshire Green)",
    x = "Month",
    y = "Mean NO2 (µg/m³)",
    color = "Year"
  )

# Display plot in RStudio
p_month

# Save plot to outputs folder
ggsave("outputs/figures/figure2_monthly_mean.png", 
       p_month, width = 9, 
       height = 5, 
       dpi = 300
       )



# Figure 3: Diurnal pattern (hour-of-day mean NO2 by year)

diurnal <- data_all %>%
  mutate(hour = hour(datetime)) %>%
  group_by(year, hour) %>%
  summarise(mean_NO2 = mean(NO2, na.rm = TRUE), .groups = "drop")



# Define peak periods
morning_start <- 7
morning_end   <- 10
evening_start <- 18
evening_end   <- 22

# Calculate lower boundary of y-axis for placing labels
y_bottom <- min(diurnal$mean_NO2, na.rm = TRUE)

# Create diurnal plot with highlighted peak periods
p_diurnal <- ggplot(diurnal, aes(x = hour, y = mean_NO2, color = factor(year), group = year)) +
  
  # Add shaded rectangle for morning peak period
  annotate("rect",
           xmin = morning_start,
           xmax = morning_end,
           ymin = -Inf,
           ymax = Inf,
           alpha = 0.15) +
  
  # Add shaded rectangle for evening peak period
  annotate("rect",
           xmin = evening_start,
           xmax = evening_end,
           ymin = -Inf,
           ymax = Inf,
           alpha = 0.15) +
  
  # Plot diurnal mean NO2 lines for each year
  geom_line(linewidth = 1) +
  
  # Format x-axis to show every 2 hours
  scale_x_continuous(breaks = seq(0, 23, 2)) +
  
  # Add plot title and axis labels
  labs(
    title = "Diurnal variation of NO2 by year (Devonshire Green)",
    x = "Hour of day",
    y = "Mean NO2 (µg/m³)",
    color = "Year"
  ) +
  
  # Add label for morning peak
  annotate("label",
           x = (morning_start + morning_end)/2,
           y = y_bottom + 1,
           label = "Morning peak",
           color = "white",
           fill = "black",
           label.size = 0,
           size = 3) +
  
  # Add label for evening peak
  annotate("label",
           x = (evening_start + evening_end)/2,
           y = y_bottom + 1,
           label = "Evening peak",
           color = "white",
           fill = "black",
           label.size = 0,
           size = 3)

p_diurnal


# Save annotated diurnal plot to file 
ggsave("outputs/figures/figure3_diurnal_mean_annotated.png", 
       p_diurnal, width = 9, height = 5, dpi = 300)
