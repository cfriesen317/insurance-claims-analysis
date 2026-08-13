-- Insurance Claims Analysis
-- Phase 3: Geographic Data Enrichment 
-- Purpose: Enrich claims data with geographic information

-- Rename imported lookup table for consistency 
alter table claims_analysis.uszips
rename to zip_lookup;

-- Standardize ZIP code format and store as text to preserve leading zeros 
alter table claims_analysis.zip_lookup
alter column zip 
type varchar(5)
using LPAD(zip::text, 5,'0');

-- Add geographic region field for regional claims analysis
alter table claims_analysis.zip_lookup
add column region varchar(20);

-- Assign states to geographic regions
update claims_analysis.zip_lookup
set region = 
	case
		when state_name in (
			'Connecticut','Maine','Massachusetts',
            'New Hampshire','Rhode Island',
            'Vermont','New Jersey','New York',
            'Pennsylvania'
        ) then 'Northeast'
        when state_name in (
        	'Illinois','Indiana','Michigan',
            'Ohio','Wisconsin','Iowa',
            'Kansas','Minnesota','Missouri',
            'Nebraska','North Dakota',
            'South Dakota'
        ) then 'Midwest'
        when state_name in (
         	'Delaware','Florida','Georgia',
            'Maryland','North Carolina',
            'South Carolina','Virginia',
            'West Virginia','Alabama',
            'Kentucky','Mississippi',
            'Tennessee','Arkansas',
            'Louisiana','Oklahoma','Texas'
        ) then 'South'
        when state_name in (
        	'Arizona','Colorado','Idaho',
            'Montana','Nevada','New Mexico',
            'Utah','Wyoming','Alaska',
            'California','Hawaii',
            'Oregon','Washington'
        ) then 'West'
        else 'Other'
	end;
	
-- Validate geographic region assignment
select 
	region, 
	count(*) as zip_count
from claims_analysis.zip_lookup
group by region 
order by zip_count desc;

-- Check for missing regions
select count(*) as missing_regions
from claims_analysis.zip_lookup
where region is null;

-- Validate claims ZIP data type before joining
select column_name, data_type
from information_schema.columns
where table_schema = 'claims_analysis'
and table_name = 'claims_clean'
and column_name = 'zip_code';

-- Validate ZIP lookup match rate to measure successful geographic enrichment
select 
	count(*) as total_claims, 
	count(z.zip) as matched_claims, 
	round(
		count(z.zip) *100.0 / count(*),
		2
	) as match_rate_percent
from claims_analysis.claims_clean c
left join claims_analysis.zip_lookup z
	on c.zip_code = z.zip; 

-- Count claims with no ZIP
select COUNT(*)
from claims_analysis.claims_clean
where zip_code is null;

-- Identify unmatched ZIP codes
select c.zip_code, count(*) as claims
from claims_analysis.claims_clean c
left join claims_analysis.zip_lookup z
    on c.zip_code = z.zip
where z.zip is null
group by c.zip_code
order by claims desc;

-- Check unmatched ZIPs in lookup table
select *
from claims_analysis.zip_lookup
where zip in ('85077', '50011', '20160');

-- Count ZIPs in lookup table
select count(*) from claims_analysis.zip_lookup;

-- Check for duplicate ZIPs
select
    count (*) as total_rows,
    count(distinct zip) as distinct_zips
from claims_analysis.zip_lookup;

-- Create geographically enriched claims view 
create or replace view claims_analysis.claims_analysis_view as 
select 
	c.*,
	z.state_name,
	z.region
from claims_analysis.claims_clean c
left join claims_analysis.zip_lookup z
	on c.zip_code = z.zip; 

-- Validate analysis view row count
select count(*) 
from claims_analysis.claims_analysis_view;
