-- Insurance Claims Analysis
-- Phase 1: Data Validation 
-- Purpose: Assess imported claims data quality before analysis 

select *
from claims_analysis.claims_raw
limit 10;

-- Verify source missing-value markers (*) were converted to NULL during import 
select *
from claims_analysis.claims_raw 
where claim_number = 23016960;

-- Check number of NULL values after import
-- Test column: injury_claims
select COUNT(*) as missing_injury_claims
from claims_analysis.claims_raw 
where injury_claim is null;

-- Check row count
select COUNT(*) 
from claims_analysis.claims_raw;

-- Check for duplicate claim numbers
select claim_number, COUNT(*)
from claims_analysis.claims_raw
group by claim_number 
having count(*) >1; 

-- Check data types in each column 
select 
	column_name,
	data_type, 
	character_maximum_length, 
	numeric_precision,
	numeric_scale, 
	is_nullable
from information_schema.columns 
where table_schema = 'claims_analysis'
	and table_name = 'claims_raw'
 order by ordinal_position; 

-- Check for negative claim amounts
select *
from claims_analysis.claims_raw 
where total_claim < 0; 

-- Check age range 
select * 
from claims_analysis.claims_raw 
where age_of_driver < 0 
	or age_of_driver > 120;

-- Check claim date rante 
select 
	MIN(claim_date) as earliest_claim_date, 
	max(claim_date) as latest_claim_date
from claims_analysis.claims_raw; 