-- Create the database
create database CreditCardUsageDB;
use CreditCardUsageDB;

-- Create the dim_customers table
create table dim_customers
(customer_id varchar(20), age_group varchar(20),  city varchar(20),  occupation varchar(30), gender varchar(20), marital_status varchar(20), average_income int);

 -- Load data from CSV file into the dim_customers table
select * from dim_customers;
load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\dim_customers.csv" into table dim_customers
fields terminated by ','
ENCLOSED BY '"'
lines terminated by '\n'
ignore 1 rows;


-- Create the fact_spends table
create table fact_spends
(customer_id varchar(20), month varchar(20), category varchar(50), payment_type varchar(20), spend int);

-- Load data from CSV file into the dim_customers table
select * from fact_spends;
load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\fact_spends.csv" into table fact_spends
fields terminated by ','
ENCLOSED BY '"'
lines terminated by '\n'
ignore 1 rows;


-- Check for missing values in the 'category' column
SELECT *
FROM fact_spends
WHERE category IS NULL;

-- Check for missing values in the 'spend' column
SELECT *
FROM fact_spends
WHERE spend IS NULL;

-- Check for missing values in the 'city' column
SELECT *
FROM dim_customers
WHERE city IS NULL;

-- Check for missing values in the 'customer_id' column
SELECT *
FROM dim_customers
WHERE customer_id IS NULL;

-- total income 
SELECT sum(average_income) AS total_income
FROM dim_customers;

-- total spend 
SELECT SUM(spend) AS total_spend
FROM fact_spends;


-- Demographic Insights
-- Age group classification 
SELECT age_group,
  COUNT(*) AS customer_count
FROM merged_customer_info
GROUP BY age_group;

-- Gender classification 
SELECT gender, occupation,
  COUNT(*) AS customer_count
FROM merged_customer_info
GROUP BY gender, occupation
order by customer_count desc
;

-- occupation classification 
SELECT occupation,
  COUNT(*) AS customer_count
FROM dim_customers
GROUP BY occupation
order by customer_count desc;

-- city classification 
SELECT city,
  COUNT(*) AS customer_count
FROM dim_customers
GROUP BY city;

-- marital_status classification 
SELECT marital_status, 
  COUNT(*) AS customer_count
FROM merged_customer_info
GROUP BY marital_status
order by customer_count desc;

-- average income utility percentage 
SELECT  
avg(spend)/avg(average_income)*100 as avg_income_utility
FROM merged_customer_info
;


-- creating new table as merged_customer_info by using inner join 
CREATE TABLE merged_customer_info AS
SELECT dim.customer_id, dim.age_group, dim.city, dim.occupation, 
dim.gender, dim.marital_status, dim.average_income, fa.spend
FROM dim_customers dim
INNER JOIN fact_spends fa ON dim.customer_id = fa.customer_id;

-- Avg Income Utilisation % over occupation:
SELECT occupation,
       (avg(spend) / avg(average_income) * 100) AS avg_income_utilization
FROM merged_customer_info
group by occupation;

-- -- Avg Income Utilisation % over city:
SELECT city,
       (avg(spend) / avg(average_income) * 100) AS avg_income_utilization
FROM merged_customer_info
group by city;

-- Avg Income Utilisation % over age group:
SELECT age_group,
       (avg(spend) / avg(average_income) * 100) AS avg_income_utilization
FROM merged_customer_info
group by age_group;

-- Spending Insights:
-- Spending by age_group:
SELECT age_group,
  sum(spend) AS total_spend
FROM merged_customer_info
GROUP BY age_group
order by total_spend desc;

-- Spending by City:
SELECT city, occupation,
  sum(spend) AS total_spend
FROM merged_customer_info
GROUP BY city, occupation
order by total_spend desc;

-- Spending by gender:
SELECT gender,
  sum(spend) AS total_spend
FROM merged_customer_info
GROUP BY gender
order by total_spend desc;

-- Spending by occupation:
SELECT occupation,
  SUM(spend) AS total_spend
FROM merged_customer_info
GROUP BY occupation;


-- total spend per category
SELECT category, sum(spend) AS total_spend
FROM fact_spends
GROUP BY category
ORDER BY total_spend DESC;

-- monthly spending pattern 
SELECT month, sum(spend) AS total_spend
FROM fact_spends
GROUP BY month
ORDER BY MONTH desc;


-- High-Value Users:
SELECT age_group, gender, occupation, city,
sum(spend) AS total_spend
FROM merged_customer_info
GROUP BY age_group, gender, occupation, city
ORDER BY total_spend DESC
;

-- To find out how customers typically pay for purchases
SELECT payment_type,
  COUNT(*) AS transaction_count,
  ROUND(SUM(spend) / COUNT(*), 2) AS average_transaction_amount
FROM fact_spends
GROUP BY payment_type
ORDER BY transaction_count DESC;














