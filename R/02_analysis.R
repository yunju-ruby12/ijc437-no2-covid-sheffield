# ============================================
# NO2 COVID Sheffield (Devonshire Green) Project
# Used for both IJC437 & IJC445
# 02_analysis.R
# ============================================

# Load libraries==============================
library(tidyverse)
library(lubridate)
library(dplyr)
library(ggplot2)

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



# Add hour, weekday and weekend flag for diurnal / weekday-weekend analysis (RQ2)
data_all <- data_all %>%
  mutate(
    hour = hour(datetime),
    weekday_name = wday(datetime, label = TRUE, abbr = FALSE, week_start = 1),
    is_weekend = wday(datetime, week_start = 1) %in% c(6, 7)
  )




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

# High-contrast pollution narrative palette
year_colors <- c(
  "2018" = "#D7191C",  # strong red (higher pollution)
  "2020" = "#7B3294",  # deep purple (transition)
  "2023" = "#1A9641"   # strong green (lower pollution)
)


# Figure 1: Distribution of NO2 by year (RQ1) ============
p_box <- ggplot(data_all,
                aes(x = factor(year),
                    y = NO2,
                    fill = factor(year))) +
  
  geom_boxplot(alpha = 0.7) +
  
  scale_fill_manual(values = year_colors, name = "Year") +
  
  labs(
    title = "Distribution of Hourly NO2 by Year",
    x = "Year",
    y = "Hourly NO2 Concentration (µg/m³)",
    fill = "Year"
  ) +
  
  theme_minimal()


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
  scale_color_manual(values = year_colors, name = "Year") +
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



# Figure 3: Diurnal variation (Ridgeline plot)

# Build the diurnal summary table (mean NO2 by year and hour)
diurnal <- data_all %>%
  group_by(year, hour) %>%
  summarise(mean_NO2 = mean(NO2, na.rm = TRUE), .groups = "drop")

# Define peak windows
morning_start <- 7
morning_end   <- 10
evening_start <- 18
evening_end   <- 22

# Set label vertical position (between 10–15)
peak_label_y <- 12.5

# Identify peak hours within each window
peak_data <- diurnal %>%
  group_by(year) %>%
  summarise(
    morning_hour = hour[hour >= morning_start & hour <= morning_end]
    [which.max(mean_NO2[hour >= morning_start & hour <= morning_end])],
    morning_value = max(mean_NO2[hour >= morning_start & hour <= morning_end]),
    evening_hour = hour[hour >= evening_start & hour <= evening_end]
    [which.max(mean_NO2[hour >= evening_start & hour <= evening_end])],
    evening_value = max(mean_NO2[hour >= evening_start & hour <= evening_end])
  ) %>%
  pivot_longer(
    cols = c(morning_hour, evening_hour, morning_value, evening_value),
    names_to = c("peak_type", ".value"),
    names_pattern = "(morning|evening)_(hour|value)"
  )

# Create plot
p_diurnal_curve <- ggplot(diurnal,
                          aes(x = hour, y = mean_NO2,
                              color = factor(year),
                              group = year)) +
  
  # Shaded peak windows
  annotate("rect",
           xmin = morning_start,
           xmax = morning_end,
           ymin = 0,
           ymax = Inf,
           fill = "grey70",
           alpha = 0.15) +
  
  annotate("rect",
           xmin = evening_start,
           xmax = evening_end,
           ymin = 0,
           ymax = Inf,
           fill = "grey70",
           alpha = 0.15) +
  
  # Diurnal curves
  geom_line(linewidth = 1.1) +
  
  # Peak points
  geom_point(data = peak_data,
             aes(x = hour, y = value),
             size = 3,
             show.legend = FALSE) +
  
  # Peak value labels
  geom_text(data = peak_data,
            aes(x = hour,
                y = ifelse(year == 2023,
                           value - 2,   # 2023 put under lines
                           value + 2),  # others put above
                label = round(value, 1)),
            size = 3,
            show.legend = FALSE) +
  
  # Custom colours
  scale_color_manual(values = year_colors, name = "Year") +
  
  # Axis formatting
  scale_x_continuous(breaks = seq(0, 23, 2)) +
  
  labs(
    title = "Diurnal variation of NO2 by year (Devonshire Green)",
    x = "Hour of day",
    y = "Mean NO2 (µg/m³)"
  ) +
  
  # Peak window labels (moved upward to 12.5)
  annotate("label",
           x = (morning_start + morning_end) / 2,
           y = peak_label_y,
           label = "Morning Peak",
           fill = "black",
           color = "white",
           size = 3) +
  
  annotate("label",
           x = (evening_start + evening_end) / 2,
           y = peak_label_y,
           label = "Evening Peak",
           fill = "black",
           color = "white",
           size = 3) +
  
  theme_minimal()

p_diurnal_curve

ggsave("outputs/figures/figure3_diurnal_curve_peaks.png",
       p_diurnal_curve, width = 9, height = 5, dpi = 300)

# Figure 4: Month × Hour Heatmap
# Add month and hour variables extracted from datetime
# Aggregate mean NO2 by year, month and hour
heatmap_data <- data_all %>%
  group_by(year, month, hour) %>%
  summarise(mean_NO2 = mean(NO2, na.rm = TRUE)) %>%
  ungroup()


# Set custom year order for faceting (swap 2018 and 2023)
heatmap_data <- heatmap_data %>%
  mutate(year = factor(year, levels = c(2023, 2020, 2018)))


# Create heatmap visualisation showing interaction between seasonal and diurnal patterns
p_heatmap <- ggplot(heatmap_data,
                    aes(x = hour, y = month, fill = mean_NO2)) +
  
  # Use tiles to represent mean NO2 concentration
  geom_tile() +
  
  # Separate panels by year for comparison
  facet_wrap(~ year, ncol = 1) +
  
  # Apply perceptually uniform colour scale
  scale_fill_viridis_c(
    option = "C",
    direction = -1,
    name = "Mean NO2 (µg/m³)"
  ) +
  
  # Display hour labels every 2 hours
  scale_x_continuous(breaks = seq(0, 23, 2)) +
  
  # Add descriptive title and axis labels
  labs(
    title = "Monthly and Diurnal Structure of NO2 Concentrations",
    x = "Hour of Day",
    y = "Mean NO2 (µg/m³)"
  ) +
  
  # Use minimal theme for clarity
  theme_minimal()


# Display heatmap in RStudio
p_heatmap


# Save heatmap to outputs folder
ggsave(
  "outputs/figures/figure4_heatmap_month_hour.png",
  p_heatmap,
  width = 8,
  height = 10,
  dpi = 300)



# Figure 5:  Monthly NO2 Difference Relative to 2020 Baseline
# Extract 2020 monthly mean as baseline
baseline_2020 <- monthly %>%
  filter(year == 2020) %>%
  select(month_num, baseline_NO2 = mean_NO2)

# Join baseline back and calculate difference
monthly_diff <- monthly %>%
  left_join(baseline_2020, by = "month_num") %>%
  mutate(
    diff_from_2020 = mean_NO2 - baseline_NO2,
    ymin = pmin(0, diff_from_2020),   # lower ribbon bound
    ymax = pmax(0, diff_from_2020)    # upper ribbon bound
  ) %>%
  filter(year != 2020)   # remove baseline from delta plot


# Create Ribbon + Line plot
p_ribbon <- ggplot(
  monthly_diff,
  aes(x = month, y = diff_from_2020, group = year)
) +
  
  # Ribbon shows magnitude of difference from 2020
  geom_ribbon(
    aes(ymin = ymin, ymax = ymax, fill = factor(year)),
    alpha = 0.25
  ) +
  
  # Line shows structure of monthly deviation
  geom_line(
    aes(color = factor(year)),
    linewidth = 1.2
  ) +
  
  # Add points for readability
  geom_point(
    aes(color = factor(year)),
    size = 2.4
  ) +
  
  # Reference line at zero (no difference)
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    linewidth = 0.7
  ) +
  
  # Apply consistent year colour palette
  scale_color_manual(values = year_colors, name = "Year") +
  scale_fill_manual(values = year_colors, name = "Year") +
  
  # Labels
  labs(
    title = "Monthly NO2 Change Relative to 2020 Baseline",
    subtitle = "Positive values indicate higher NO2 than 2020; negative values indicate lower",
    x = "Month",
    y = expression(Delta*" Mean NO"[2]*" vs 2020 ("*mu*"g/m"^3*")")
  ) +
  
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank()
  )

# Display plot
p_ribbon


# Save figure
ggsave("outputs/figures/figure5_delta_vs_2020_ribbon.png",
       p_ribbon, width = 9, height = 5, dpi = 300)



  

# Classify 2020 into lockdown phases (RQ3) 
d2020_phase <- d2020 %>%
  mutate(
    date_only = as_date(datetime),
    phase = case_when(
      date_only < as_date("2020-03-23") ~ "Pre-lockdown",
      (date_only >= as_date("2020-03-23") & date_only <= as_date("2020-06-30")) |
        (date_only >= as_date("2020-11-05") & date_only <= as_date("2020-12-02")) ~ "Lockdown",
      TRUE ~ "Eased"
      ),
    phase = factor(phase, levels = c("Pre-lockdown", "Lockdown", "Eased")),
    is_weekend = wday(datetime, week_start = 1) %in% c(6, 7),
    hour = hour(datetime)
    )


# Figure 6: boxplot of NO2 by 2020 lockdown phase
p_phase_box <- ggplot(d2020_phase, aes(x = phase, y = NO2, fill = phase)) +
  geom_boxplot(alpha = 0.7) +
  labs(
    title = "NO2 by 2020 COVID Restriction Phase (Devonshire Green)",
    x = NULL,
    y = "Hourly NO2 (µg/m³)"
    ) +
  theme_minimal() +
  theme(legend.position = "none")
	 
p_phase_box

ggsave("outputs/figures/figure6_2020_phase_boxplot.png",
       p_phase_box, width = 8, height = 5.5, dpi = 300)





# Weekday vs weekend WITHIN 2020, by phase (RQ3)
wk_by_phase <- d2020_phase %>%
  group_by(phase, is_weekend) %>%
  summarise(mean_NO2 = mean(NO2, na.rm = TRUE), n = n(), .groups = "drop") %>%
  mutate(day_type = if_else(is_weekend, "Weekend", "Weekday"))


p_wk_phase <- ggplot(wk_by_phase, aes(x = phase, y = mean_NO2, fill = day_type)) +
  geom_col(position = position_dodge(width = 0.9)) +
  geom_text(
    aes(label = round(mean_NO2, 1)),
    position = position_dodge(width = 0.9),
    vjust = -0.4,
    size = 3.3
  ) +
  labs(
    title = "Weekday vs Weekend Mean NO2 by 2020 Phase (Devonshire Green)",
    x = NULL,
    y = "Mean Hourly NO2 (µg/m³)",
    fill = NULL
  ) +
  theme_minimal() +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12)))  # leave headroom for labels

p_wk_phase

ggsave("outputs/figures/figure7_weekday_weekend_by_phase.png",
       p_wk_phase, width = 8, height = 5, dpi = 300)

write_csv(wk_by_phase, "outputs/tables/weekday_weekend_by_phase.csv")





# Weekday vs weekend ACROSS ALL THREE YEARS (RQ2)
wk_by_year <- data_all %>%
  group_by(year, is_weekend) %>%
  summarise(mean_NO2 = mean(NO2, na.rm = TRUE), n = n(), .groups = "drop") %>%
  mutate(day_type = if_else(is_weekend, "Weekend", "Weekday"))


p_wk_year <- ggplot(wk_by_year, aes(x = factor(year), y = mean_NO2, fill = day_type)) +
  geom_col(position = "dodge") +
  geom_text(
    aes(label = round(mean_NO2, 1)),
    position = position_dodge(width = 0.9),
    vjust = -0.4,
    size = 3.3) +
  labs(
    title = "Weekday vs Weekend Mean NO2 by Year (Devonshire Green)",
    x = "Year",
    y = "Mean Hourly NO2 (µg/m³)",
    fill = NULL
  ) +
  theme_minimal()

p_wk_year

ggsave("outputs/figures/figure8_weekday_weekend_by_year.png",
       p_wk_year, width = 8, height = 5, dpi = 300)

write_csv(wk_by_year, "outputs/tables/weekday_weekend_by_year.csv")




# Statistical test 1: Welch's t-test, weekday vs weekend, by 2020 phase 
t_test_by_phase <- d2020_phase %>%
  group_by(phase) %>%
  summarise(
    t_stat = t.test(NO2 ~ is_weekend)$statistic,
    p_value = t.test(NO2 ~ is_weekend)$p.value,
    .groups = "drop"
  )
print(t_test_by_phase)
write_csv(t_test_by_phase, "outputs/tables/weekday_weekend_ttest_by_phase.csv")



# Statistical test 2: Welch's t-test, weekday vs weekend, by year
t_test_by_year <- data_all %>%
  group_by(year) %>%
  summarise(
    t_stat = t.test(NO2 ~ is_weekend)$statistic,
    p_value = t.test(NO2 ~ is_weekend)$p.value,
    .groups = "drop"
  )
print(t_test_by_year)
write_csv(t_test_by_year, "outputs/tables/weekday_weekend_ttest_by_year.csv")




# Statistical test 3: one-way ANOVA, weekday NO2 across the 3 phases 
anova_model <- aov(NO2 ~ phase, data = d2020_phase %>% filter(!is_weekend))
anova_summary <- summary(anova_model)
print(anova_summary)

