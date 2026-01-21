# Customer Churn Analytics Pipeline

## Project Goal
This pipeline processes customer churn data from a raw CSV into a structured format suitable for analytics:
- Raw table (raw_zone)
- Cleaned table (clean_zone)
- Dimensions & Facts (customer_churn_analytics)

## Setup
- PostgreSQL required
- Place your CSV file in `data/raw/Customer_Churn.csv`
- Update path in `02_create_raw_table` COPY command if needed

## How to Run
Run the scripts in order:
1. `01_create_schemas`
2. `02_create_raw_table`
3. `03_load_data`
4. `04_clean_data`
5. `05_build_dimension`
6. `06_build_fact`

Or run `07_full_pipeline_script.sql` to execute all steps at once.

## Tables
- `raw_zone.customer_churn_raw`
- `clean_zone.customer_churn_clean`
- `customer_churn_analytics.dim_customer`
- `customer_churn_analytics.dim_service`
- `customer_churn_analytics.dim_churn_risk`
- `customer_churn_analytics.fact_customer_churn`


```
customer_churn_pipeline/
│
├─ README.md
├─ data/
│   └─ raw/                   
├─ sql/
└── full_pipeline.sql
```
