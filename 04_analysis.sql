-- Insurance Claims Analysis 
-- Phase 4: Analysis 
-- Purpose: Determine factors associated with higher claim costs and longer resolution time. 

-- Question 1: Factors associated with higher claim costs
-- Average claim amount by vehicle category
select 
	vehicle_category, 
	count(*) as claim_count,
	round(avg(total_claim), 2) as avg_claim_amount
from claims_analysis.claims_analysis_view
group by vehicle_category
order by avg_claim_amount desc;

-- Average claim amount by vehicle price group
select
	case
		when vehicle_price < 15000 then 'Low Value'
		when vehicle_price < 30000 then 'Medium Value'
		when vehicle_price < 50000 then 'High Value'
		else 'Very High Value'
	end as vehicle_value_group,
	count(*) as claim_count,
	round(avg(total_claim), 2) as avg_claim_amount	
from claims_analysis.claims_analysis_view
group by vehicle_value_group
order by avg_claim_amount desc;

-- Average claim amount by accident site
select
	accident_site,
	count(*) as claim_count,
	round(avg(total_claim), 2) as avg_claim_amount
from claims_analysis.claims_analysis_view
group by accident_site
order by avg_claim_amount desc;

-- Average claim amount by safety rating group
with safety_groups as (
	select
		safety_rating,
		total_claim,
		ntile(3) over (order by safety_rating) as safety_group
	from claims_analysis.claims_analysis_view
)

select 
	case
		when safety_group = 1 then 'Low Rating'
		when safety_group = 2 then 'Medium Rating'
		when safety_group = 3 then 'High Rating'
	end as safety_rating_group,
	count(*) as claim_count,
	round(avg(total_claim), 2) as avg_claim_amount
from safety_groups
group by safety_group
order by avg_claim_amount desc;
	
-- Average claim amount by number of previous claims
select 
	past_num_of_claims,
	count(*) as claim_count, 
	round(avg(total_claim), 2) as avg_claim_amount
from claims_analysis.claims_analysis_view
group by past_num_of_claims
order by past_num_of_claims;

-- Average claim amount by region
select
	region, 
	count(*) as claim_count, 
	round(avg(total_claim), 2) as avg_claim_amount
from claims_analysis.claims_analysis_view
group by region
order by avg_claim_amount desc; 

-- Overall claim cost distribution
select
	count(*) as claim_count,
	round(avg(total_claim), 2) as avg_claim_amount,
	round(percentile_cont(0.5) within group(order by total_claim)::numeric, 2) as median_claim_amount,
	round(min(total_claim), 2) as min_claim_amount,
	round(max(total_claim), 2) as max_claim_amount
from claims_analysis.claims_analysis_view;

-- Top 10 highest-value claims
select 
	claim_number, 
	total_claim, 
	vehicle_category,
	vehicle_price,
	accident_site,
	safety_rating,
	past_num_of_claims,
	fraud_reported,
	region
from claims_analysis.claims_analysis_view
order by total_claim desc
limit 10;


-- Question 2: Factors associated with longer claim resolution times
-- Average days open by accident site
select 
	accident_site,
	count(*) as claim_count,
	round(avg(days_open)::numeric, 2) as avg_days_open
from claims_analysis.claims_analysis_view
group by accident_site
order by avg_days_open desc;

-- Average days open by claim channel
select
	channel,
	count(*) as claim_count,
	round(avg(days_open)::numeric, 2) as avg_days_open
from claims_analysis.claims_analysis_view
group by channel
order by avg_days_open desc;

-- Average days open by fraud status 
select
	fraud_reported, 
	count(*) as claim_count,
	round(avg(days_open)::numeric, 2) as avg_days_open
from claims_analysis.claims_analysis_view
group by fraud_reported 
order by avg_days_open desc;

-- Average days open by number of form defects
select
	form_defects,
	count(*) as claim_count,
	round(avg(days_open)::numeric, 2) as avg_days_open
from claims_analysis.claims_analysis_view
group by form_defects
order by avg_days_open desc;

-- Average days open by region
select
	region, 
	count(*) as claim_count,
	round(avg(days_open)::numeric, 2) as avg_days_open
from claims_analysis.claims_analysis_view
group by region
order by avg_days_open desc; 

