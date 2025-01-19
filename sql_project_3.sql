-- Creating Table
DROP TABLE IF EXISTS walmart;
CREATE TABLE walmart(
     invoice_id INT PRIMARY KEY,	
	 Branch	VARCHAR(50),
	 City VARCHAR(50),
	 category VARCHAR(50),	
	 unit_price	FLOAT,
	 quantity FLOAT,	
	 date DATE,	
	 time TIME,	
	 payment_method VARCHAR(50),	
	 rating	FLOAT,
	 profit_margin FLOAT,	
	 total FLOAT
);


-- Checking if the table formed or not
SELECT * FROM walmart;



-- Checking all the null values in the dataset
SELECT 
    COUNT(*) AS total_rows_with_nulls
FROM 
    walmart
WHERE 
    invoice_id IS NULL
    OR Branch IS NULL
    OR City IS NULL
    OR category IS NULL
    OR unit_price IS NULL
    OR quantity IS NULL
    OR date IS NULL
    OR time IS NULL
    OR payment_method IS NULL
    OR rating IS NULL
    OR profit_margin IS NULL
    OR total IS NULL;


--Checking Null values in each column
SELECT
    COUNT(*) FILTER (WHERE invoice_id IS NULL) AS invoice_id_nulls,
    COUNT(*) FILTER (WHERE Branch IS NULL) AS Branch_nulls,
    COUNT(*) FILTER (WHERE City IS NULL) AS City_nulls,
    COUNT(*) FILTER (WHERE category IS NULL) AS category_nulls,
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS unit_price_nulls,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS quantity_nulls,
    COUNT(*) FILTER (WHERE date IS NULL) AS date_nulls,
    COUNT(*) FILTER (WHERE time IS NULL) AS time_nulls,
    COUNT(*) FILTER (WHERE payment_method IS NULL) AS payment_method_nulls,
    COUNT(*) FILTER (WHERE rating IS NULL) AS rating_nulls,
    COUNT(*) FILTER (WHERE profit_margin IS NULL) AS profit_margin_nulls,
    COUNT(*) FILTER (WHERE total IS NULL) AS total_nulls
FROM walmart;



--Q.1 Find different payment method and number of transactions, number of qty sold
SELECT 
    payment_method AS payment_method,
    COUNT(*) AS number_of_transactions,
    SUM(quantity) AS total_quantity_sold
FROM 
    walmart
GROUP BY 
    payment_method
ORDER BY 
    number_of_transactions DESC;


--Q.2 Which category recieved the highest avg rating in each branch
	WITH category_avg_ratings AS (
    SELECT
        Branch,
        category,
        AVG(rating) AS avg_rating
    FROM 
        walmart
    GROUP BY 
        Branch, category
)
SELECT
    Branch,
    category,
    avg_rating
FROM 
    category_avg_ratings
WHERE 
    (Branch, avg_rating) IN (
        SELECT 
            Branch, MAX(avg_rating)
        FROM 
            category_avg_ratings
        GROUP BY 
            Branch
    )
ORDER BY 
    Branch, avg_rating DESC;


-- Q.3 Identify the busiest day for each branch based on the number of transactions
WITH branch_day_transactions AS (
    SELECT
        Branch,
        date,
        COUNT(*) AS number_of_transactions
    FROM
        walmart
    GROUP BY
        Branch, date
),
busiest_days AS (
    SELECT
        Branch,
        date AS busiest_day,
        number_of_transactions,
        RANK() OVER (PARTITION BY Branch ORDER BY number_of_transactions DESC) AS rank
    FROM
        branch_day_transactions
)
SELECT
    Branch,
    busiest_day,
    number_of_transactions
FROM
    busiest_days
WHERE
    rank = 1
ORDER BY
    Branch, busiest_day;


-- Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
	SELECT 
    payment_method,
    SUM(quantity) AS total_quantity
FROM 
    walmart
GROUP BY 
    payment_method
ORDER BY 
    total_quantity DESC;


-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.
SELECT
    City,
    category,
    AVG(rating) AS average_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM 
    walmart
GROUP BY 
    City, category
ORDER BY 
    City, category;


-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.
SELECT
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM
    walmart
GROUP BY
    category
ORDER BY
    total_profit DESC;


-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
SELECT
    Branch,
    payment_method AS preferred_payment_method
FROM (
    SELECT
        Branch,
        payment_method,
        COUNT(*) AS transaction_count,
        RANK() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rank
    FROM
        walmart
    GROUP BY
        Branch, payment_method
) ranked_payment_methods
WHERE
    rank = 1;


-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM time) BETWEEN 6 AND 11 THEN 'MORNING'
        WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        WHEN EXTRACT(HOUR FROM time) BETWEEN 18 AND 23 THEN 'EVENING'
        ELSE 'NIGHT'
    END AS shift,
    COUNT(invoice_id) AS number_of_invoices
FROM
    walmart
GROUP BY
    shift
ORDER BY
    number_of_invoices DESC;



-- Q.9 Which branch experienced the largest decrease in revenue compared to the previous year.
WITH yearly_revenue AS (
    SELECT
        Branch,
        EXTRACT(YEAR FROM date) AS year,
        SUM(total) AS total_revenue
    FROM
        walmart
    GROUP BY
        Branch, EXTRACT(YEAR FROM date)
),
revenue_change AS (
    SELECT
        a.Branch,
        a.year AS current_year,
        a.total_revenue AS current_revenue,
        b.total_revenue AS previous_revenue,
        (a.total_revenue - b.total_revenue) AS revenue_difference
    FROM
        yearly_revenue a
    LEFT JOIN
        yearly_revenue b
    ON
        a.Branch = b.Branch AND a.year = b.year + 1
)
SELECT
    Branch,
    current_year,
    revenue_difference
FROM
    revenue_change
WHERE
    revenue_difference IS NOT NULL
ORDER BY
    revenue_difference ASC
LIMIT 1;










