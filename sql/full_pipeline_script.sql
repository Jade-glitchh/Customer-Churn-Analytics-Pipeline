-- ============================================
-- Script: End-to-End SQL Pipeline Script
-- Author: Jadesola
-- Date: 2026-01-09
-- Purpose: Create a Customer Churn SQL script that: Create schemas, Create raw tables, Loads data, Cleans data, Build dimensions, Build facts
-- ============================================

-- Create Schema
 CREATE SCHEMA IF NOT EXISTS raw_zone; 

-- Create raw tables
CREATE TABLE IF NOT EXISTS raw_zone.customer_churn_raw (
    customer_id VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    senior_citizen BOOLEAN,
    partner BOOLEAN,
    dependents BOOLEAN,
    tenure INTEGER,
    phone_service BOOLEAN,
    multiple_lines VARCHAR(30),
    internet_service VARCHAR(30),
    online_security VARCHAR(30),
    online_backup VARCHAR(30),
    device_protection VARCHAR(30),
    tech_support VARCHAR(30),
    streaming_tv VARCHAR(30),
    streaming_movies VARCHAR(30),
    contract VARCHAR(30),
    paperless_billing BOOLEAN,
    payment_method VARCHAR(50),
    monthly_charges DECIMAL(10,2),
    total_charges DECIMAL(10,2),
    churn BOOLEAN,
    high_risk_customers BOOLEAN,
    total_services INTEGER,
    monthly_charge_bin VARCHAR(20)
);

-- Load Data
\COPY raw_zone.customer_churn_raw FROM 'C:/users/dell/Documents/Custom Office Templates/Customer_Churn_Project/Data/cleaned_data.csv' DELIMITER ',' CSV HEADER NULL ' ';

-- Clean Data
-- Step 1: Remove duplicates
DELETE FROM raw_zone.customer_churn_raw
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM raw_zone.customer_churn_raw
    GROUP BY
        customer_id,
        gender, senior_citizen, partner, dependents, tenure,
        phone_service, multiple_lines, internet_service, online_security,
        online_backup, device_protection, tech_support, streaming_tv,
        streaming_movies, contract , paperless_billing, payment_method,
        monthly_charges, total_charges, churn, high_risk_customers,
        total_services, monthly_charge_bin
);

-- Step 2: Standardize string columns
UPDATE raw_zone.customer_churn_raw
SET payment_method = INITCAP(TRIM(REGEXP_REPLACE(payment_method, '\s+', ' ', 'g')));

-- Step 3: Insert cleaned data into the clean zone
CREATE SCHEMA IF NOT EXISTS clean_zone;
CREATE TABLE IF NOT EXISTS clean_zone.customer_churn_clean (
    customer_id VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    senior_citizen BOOLEAN,
    partner BOOLEAN,
    dependents BOOLEAN,
    tenure INTEGER,
    phone_service BOOLEAN,
    multiple_lines VARCHAR(30),
    internet_service VARCHAR(30),
    online_security VARCHAR(30),
    online_backup VARCHAR(30),
    device_protection VARCHAR(30),
    tech_support VARCHAR(30),
    streaming_tv VARCHAR(30),
    streaming_movies VARCHAR(30),
    contract_type VARCHAR(30),
    paperless_billing BOOLEAN,
    payment_method VARCHAR(50),
    monthly_charges DECIMAL(10,2),
    total_charges DECIMAL(10,2),
    churn BOOLEAN,
    high_risk_customers BOOLEAN,
    total_services INTEGER,
    monthly_charge_bin VARCHAR(20)
);
TRUNCATE TABLE clean_zone.customer_churn_clean;
INSERT INTO clean_zone.customer_churn_clean (
    customer_id, gender, senior_citizen, partner, dependents, tenure,
    phone_service, multiple_lines, internet_service, online_security,
    online_backup, device_protection, tech_support, streaming_tv,
    streaming_movies, contract_type, paperless_billing, payment_method,
    monthly_charges, total_charges, churn, high_risk_customers,
    total_services, monthly_charge_bin
)
SELECT DISTINCT
    customer_id, gender, senior_citizen, partner, dependents, tenure,
    phone_service, multiple_lines, internet_service, online_security, online_backup, device_protection,
    tech_support, streaming_tv, streaming_movies, contract AS contract_type,
    paperless_billing, payment_method, monthly_charges, total_charges,
    churn, high_risk_customers, total_services, monthly_charge_bin
FROM raw_zone.customer_churn_raw;

-- Build Dimension
CREATE SCHEMA IF NOT EXISTS customer_churn_analytics;

DROP TABLE IF EXISTS customer_churn_analytics.dim_customer;
CREATE TABLE customer_churn_analytics.dim_customer AS
SELECT DISTINCT customer_id, gender, senior_citizen, partner, dependents
FROM clean_zone.customer_churn_clean;

DROP TABLE IF EXISTS customer_churn_analytics.dim_service;
CREATE TABLE customer_churn_analytics.dim_service AS
SELECT DISTINCT phone_service, multiple_lines, internet_service,
       online_security, online_backup, device_protection,
       tech_support, streaming_tv, streaming_movies
FROM clean_zone.customer_churn_clean;

DROP TABLE IF EXISTS customer_churn_analytics.dim_churn_risk;
CREATE TABLE customer_churn_analytics.dim_churn_risk AS
SELECT DISTINCT churn, high_risk_customers
FROM clean_zone.customer_churn_clean;

-- Build Facts
DROP TABLE IF EXISTS customer_churn_analytics.fact_customer_churn;
CREATE TABLE customer_churn_analytics.fact_customer_churn AS
SELECT customer_id, contract_type, total_services, tenure, churn
FROM clean_zone.customer_churn_clean;