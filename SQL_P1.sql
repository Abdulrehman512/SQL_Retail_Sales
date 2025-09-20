DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);

-- Verify Import
SELECT COUNT(*) AS total_records FROM retail_sales;

SELECT * FROM retail_sales LIMIT 10;

-- Data Cleaning

-- Check for null values
SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL 
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
    gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
    quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL;

-- Remove null records

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
    gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
    quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL;

-- Business Analysis Queries

-- 1. Sales on specific date

SELECT * FROM retail_sales WHERE sale_date = '2022-11-05';

-- 2. Clothing sales >3 units in Nov 2022

SELECT * FROM retail_sales
WHERE category = 'Clothing'
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
  AND quantity > 3;

-- 3. Total sales per category

SELECT category,
SUM(total_sale) AS net_sale,
COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;

-- 4. Average age of Beauty buyers

SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- 5. High value transactions

SELECT * FROM retail_sales WHERE total_sale > 1000;

-- 6. Transactions by gender per category

SELECT category, gender, COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- 7. Best selling month each year

SELECT year, month, avg_sale
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
    FROM retail_sales
    GROUP BY 1, 2
) t1
WHERE rank = 1;

-- 8. Top 5 customers by total sales

SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- 9. Unique customers per category

SELECT category, COUNT(DISTINCT customer_id) AS cnt_unique_cs
FROM retail_sales
GROUP BY category;

-- 10. Orders by shift

WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT shift, COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;