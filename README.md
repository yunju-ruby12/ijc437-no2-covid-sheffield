## NO₂ Variation Before, During, and After COVID-19

Devonshire Green Monitoring Station, Sheffield (2018–2023)

This project investigates how hourly nitrogen dioxide (NO₂) concentrations at a Sheffield city-centre site changed across three periods linked to different government actions: pre-COVID (2018), COVID-19 restrictions (2020), and post-COVID following the 2023 Clean Air Zone (CAZ) (2023).

Using openly available UK-AIR monitoring data, the analysis explores inter-annual differences, seasonal and diurnal (hourly) patterns, weekday/weekend contrasts, and how the temporary COVID-19 lockdown compares with the longer-term CAZ policy.

---

## Research Questions

**RQ1:** How did overall NO₂ concentrations differ between 2018, 2020 and 2023 at Devonshire Green?

**RQ2:** What diurnal (hourly) and weekday/weekend patterns can be seen in NO₂ concentrations, and how did these patterns change across the three periods?

**RQ3:** Did the temporary reduction in NO₂ during the COVID-19 lockdown behave differently from the reduction associated with the 2023 Clean Air Zone?

---

## Key Findings

- Weekday mean NO₂ fell progressively from 23.4 µg/m³ (2018) to 19.5 µg/m³ (2020) to 16.3 µg/m³ (2023), a 30.3% overall reduction.
- The weekday-weekend gap was not stable over time: 5.1% in 2018, widening to 30.3% in 2020, then narrowing to a non-significant 3.1% in 2023 (Welch's t-test, p = 0.065).
- Diurnal morning and evening peaks persisted in all years, but fell in magnitude, most sharply between 2018 and 2020.
- Within 2020, weekday NO₂ differed significantly across Pre-lockdown, Lockdown and Eased restriction phases (one-way ANOVA, F(2, 6226) = 49.82, p < 0.001).
- The 2023 reduction was smaller than the 2020 lockdown reduction but more persistent and concentrated on weekdays, consistent with Sheffield City Council's own reported CAZ-related NO₂ reduction.

---

## Visualisations

### Distribution of NO₂ by Year
![Boxplot](https://github.com/yunju-ruby12/ijc437-no2-covid-sheffield/raw/main/outputs/figures/figure1_boxplot_year.png)

### Monthly Mean NO₂
![Monthly](https://github.com/yunju-ruby12/ijc437-no2-covid-sheffield/raw/main/outputs/figures/figure2_monthly_mean.png)

### Diurnal Variation
![Diurnal](https://github.com/yunju-ruby12/ijc437-no2-covid-sheffield/raw/main/outputs/figures/figure3_diurnal_curve_peaks.png)

### Monthly and Diurnal Structure (Heatmap)
![Heatmap](https://github.com/yunju-ruby12/ijc437-no2-covid-sheffield/raw/main/outputs/figures/figure4_heatmap_month_hour.png)

### Monthly NO₂ Change Relative to 2020 Baseline
![Delta](https://github.com/yunju-ruby12/ijc437-no2-covid-sheffield/raw/main/outputs/figures/figure5_delta_vs_2020_ribbon.png)

### NO₂ by 2020 COVID Restriction Phase
![Phase boxplot](https://github.com/yunju-ruby12/ijc437-no2-covid-sheffield/raw/main/outputs/figures/figure6_2020_phase_boxplot.png)

### Weekday vs Weekend NO₂ by 2020 Phase
![Weekday weekend phase](https://github.com/yunju-ruby12/ijc437-no2-covid-sheffield/raw/main/outputs/figures/figure7_weekday_weekend_by_phase.png)

### Weekday vs Weekend NO₂ by Year
![Weekday weekend year](https://github.com/yunju-ruby12/ijc437-no2-covid-sheffield/raw/main/outputs/figures/figure8_weekday_weekend_by_year.png)

---

## Methods Overview

- Data cleaning and preprocessing in R
- Date-time processing using lubridate
- Data manipulation using tidyverse
- Visualisation using ggplot2
- Descriptive statistics (mean, median, SD, 95th percentile)
- Monthly, hourly and weekday/weekend aggregation
- 2020 restriction-phase classification (Pre-lockdown, Lockdown, Eased)
- Welch's t-tests (weekday vs weekend NO2, by year and by 2020 phase)
- One-way ANOVA (weekday NO2 across 2020 restriction phases)

---

## How to Run the Code

1️⃣ Clone the repository
git clone https://github.com/yunju-ruby12/ijc437-no2-covid-sheffield.git

2️⃣ Open in RStudio

Open the cloned folder in RStudio.

3️⃣ Install required packages (first time only)
```r
install.packages(c("tidyverse", "lubridate"))
```

4️⃣ Run scripts in order
R/01_data_cleaning.R
R/02_analysis.R

Outputs will be generated in:
outputs/figures/
outputs/tables/

---

## Project Structure
ijc437-no2-covid-sheffield/
│
├── R/
│ ├── 01_data_cleaning.R
│ └── 02_analysis.R
│
├── data_raw/
├── data_intermediate/
├── data_clean/
├── outputs/
│ ├── figures/
│ └── tables/
│
└── README.md

---

## Skills Demonstrated

- Environmental data analysis
- Time-series aggregation
- Exploratory data analysis
- Statistical testing (t-tests, ANOVA)
- Data visualisation
- Reproducible research workflow
- GitHub documentation

---

## About

This project was developed as part of the IJC437 Data Science coursework. It demonstrates analytical workflow, interpretation of environmental data, and professional code organisation.

---

## Author

Yun-Ju Chen
MSc Data Science | University of Sheffield
Skills: R, Data Analysis, Data Cleaning, Data Visualisation, Time-Series Exploration, Statistical Testing

