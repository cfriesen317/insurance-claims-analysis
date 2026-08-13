-- Insurance Claims Analysis
-- Phase 2: Data Cleaning & Preparation 
-- Purpose: Create analysis-ready claims dataset 

-- Review marital status values and data type
select distinct marital_status
from claims_analysis.claims_raw
order by marital_status;

-- Remove previous version of cleaned table before recreation 
drop table if exists claims_analysis.claims_clean; 
-- Create cleaned claims table 
create table claims_analysis.claims_clean as 
select 
	claim_number,
	-- Handle unrealistic driver ages
	case
		when age_of_driver::integer between 0 and 120 then age_of_driver::integer
		else null
	end as age_of_driver,
	-- Standardize categorical fields 
	trim(gender) as gender,
	-- Transform binary marital status field
	case
		when marital_status = 1 then 'Married'
		when marital_status = 0 then 'Not Married'
		else null
	end as marital_status,
	
	trim(accident_site) as accident_site,
	trim(channel) as channel,
	trim(vehicle_category) as vehicle_category,
	trim(vehicle_color) as vehicle_color,
	safety_rating,
	annual_income::numeric(12,2) as annual_income,
	-- Standardize ZIP code format and store as text to preserve leading zeros
	LPAD(zip_code::text, 5, '0') as zip_code,
	claim_date::date as claim_date,
	claim_day_of_week,  
	past_num_of_claims,
	witness_present,
	liab_prct as liability_percent,
	high_education as higher_education,
	-- Currency fields standardized
	vehicle_price::numeric(12,2) as vehicle_price, 
	total_claim::numeric(12,2) as total_claim, 
	injury_claim::numeric(12,2) as injury_claim,
	"policy deductible"::numeric(12,2) as policy_deductible,
	"annual premium"::numeric(12,2) as annual_premium,
	"days open" as days_open,
	"form defects" as form_defects,
	"fraud reported" as fraud_reported, 
	-- Additional analysis fields 
	extract(year from claim_date::date) as claim_year, 
	extract(month from claim_date::date) as claim_month, 
	case
		when total_claim is null then null
		when total_claim < 2000 then 'Low'
		when total_claim < 5000 then 'Medium'
		else 'High'
	end as claim_severity
from claims_analysis.claims_raw;

-- Validation checks after cleaning
-- Confirm row count
select count(*)
from claims_analysis.claims_clean;

-- Confirm claim_date converted to DATE
select column_name, data_type
from information_schema.columns
where table_schema = 'claims_analysis'
and table_name = 'claims_clean'
and column_name = 'claim_date';
	
-- Confirm unrealistic ages coverted to NULL
select *
from claims_analysis.claims_clean
where age_of_driver is null;

-- Check duplicate claim numbers 
select claim_number, COUNT(*)
from claims_analysis.claims_clean
group by claim_number
having COUNT(*) >1;

-- Confirm ZIP code stored as text 
select column_name, data_type
from information_schema.columns
where table_schema = 'claims_analysis'
and table_name = 'claims_clean'
and column_name = 'zip_code';

-- Confirm marital status categories transformed correctly
select 
	marital_status, 
	count(*) as record_count
from claims_analysis.claims_clean
group by marital_status 
order by record_count desc;