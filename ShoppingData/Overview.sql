-- View content of each table
SELECT * FROM public."customers"
-- This table contains: customer_id, customer_name, gender, age, home_address, zip_code, city, state, country

SELECT * FROM public."orders"
-- This table contains: order_id, customer_id, payment, order_date, delivery_date

SELECT * FROM public."products"
-- This table contains:product_id, product_type, product_name, size, colour, price, quantity, description

SELECT * FROM public."sales"
-- This table contains:sales_id, order_id, product_id, price_pre_unit, quantity, total_price


-- Time Related Queries:

-- Checking the number of orders set for each day with the condition that the order has been delivered
SELECT DATE("order_date") AS order_day, COUNT(*) AS order_count
FROM "orders"
WHERE "delivery_date" IS NOT NULL AND order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY order_day
ORDER BY order_day ASC;

-- Checking the orders but weekly instead of daily
SELECT DATE_TRUNC('week', "order_date") AS order_week, COUNT(*) AS order_count
FROM "orders"
WHERE "delivery_date" IS NOT NULL
GROUP BY order_week
ORDER BY order_week DESC;

-- Checking the orders for each month including total revenue, ranked from best to worst month
SELECT DATE_TRUNC('month', "order_date") AS order_month, COUNT(*) AS order_count, SUM("sales".total_price) as total_revenue
FROM "orders"
JOIN "sales" ON orders.order_id = sales.order_id
WHERE "delivery_date" IS NOT NULL
GROUP BY order_month
ORDER BY order_count DESC;

-- Checking what day of the week has the best average sales
WITH sales_by_day AS(
	SELECT DATE_PART('dow',"order_date") as day_int, SUM("total_price") as sales_total
	FROM "orders"
	JOIN "sales" ON orders.order_id = sales.order_id
	GROUP BY day_int
)
SELECT 
	CASE
		WHEN day_int = 0 THEN 'Sunday'
		WHEN day_int = 1 THEN 'Monday'
		WHEN day_int = 2 THEN 'Tuesday'
		WHEN day_int = 3 THEN 'Wednesday'
		WHEN day_int = 4 THEN 'Thursday'
		WHEN day_int = 5 THEN 'Friday'
		WHEN day_int = 6 THEN 'Saturday'
	END as day_name,
TRUNC(AVG(sales_total)) as avg_sales, 
FROM sales_by_day
GROUP BY day_int
ORDER BY avg_sales DESC;
-- Diving deeper into day's performance for each month
WITH sales_by_day AS(
	SELECT DATE_PART('dow',"order_date") as day_int, SUM("total_price") as sales_total, DATE_TRUNC('month', "order_date") as order_month
	FROM "orders"
	JOIN "sales" ON orders.order_id = sales.order_id
	GROUP BY order_month, day_int
)
SELECT 
	CASE
		WHEN day_int = 0 THEN 'Sunday'
		WHEN day_int = 1 THEN 'Monday'
		WHEN day_int = 2 THEN 'Tuesday'
		WHEN day_int = 3 THEN 'Wednesday'
		WHEN day_int = 4 THEN 'Thursday'
		WHEN day_int = 5 THEN 'Friday'
		WHEN day_int = 6 THEN 'Saturday'
	END as day_name,
TRUNC(AVG(sales_total)) as avg_sales, order_month
FROM sales_by_day
GROUP BY order_month, day_int
ORDER BY order_month ASC, avg_sales DESC;

-- Checking the most popular products in each season (catered towards australia's seasons)
WITH season_sales AS(
	SELECT product_name,
		CASE
		WHEN order_date >= '2021-06-01' AND order_date < '2021-08-30' THEN 'Winter'
		WHEN order_date >= '2021-09-01' AND order_date < '2021-11-30' THEN 'Spring'
		WHEN order_date >= '2020-12-01' AND order_date < '2021-02-28' THEN 'Summer'
		WHEN order_date >= '2021-03-01' AND order_date < '2021-05-31' THEN 'Autumn'
		END as season,
		SUM(sales.quantity) as sales_count
	FROM orders
	JOIN sales ON orders.order_id = sales.order_id
	JOIN products ON products.product_id = sales.product_id
	GROUP BY product_name, season
)
SELECT season, product_name, sales_count,
	RANK() OVER(PARTITION BY season ORDER BY sales_count DESC) as rank
FROM season_sales
WHERE season IS NOT NULL
ORDER BY season, rank;
/*
The information retrieved in this series of queries can assist with understanding how the company’s
performance is going throughout the year, with deeper information on weekly and daily performance. 
This information can also aid in advertising and prioritizing specific products such as ones found
to be more popular in specific seasons.
*/

-- State Related Queries:

-- Checking the volume of sales in each state
SELECT "customers".state, COUNT("orders".order_id) AS order_count
FROM "customers"
JOIN "orders" 
ON customers.customer_id = orders.customer_id
GROUP BY "customers".state
ORDER BY order_count DESC;

-- Average delivery time in each state
SELECT   AVG("orders".delivery_date - "orders".order_date) as avg_delivery_time, "customers".state
FROM "orders"
JOIN customers ON orders.customer_id = customers.customer_id
WHERE "orders".delivery_date IS NOT NULL
GROUP BY  "customers".state
ORDER BY avg_delivery_time DESC;

-- Finding top 3 most popular products in each state
WITH most_popular_products_by_state AS(
	SELECT "state", "product_name", SUM("sales".quantity) as total_sales,
	RANK() OVER (PARTITION BY "state" ORDER BY SUM("sales".quantity) DESC) as rank
	FROM "customers"
	JOIN orders ON customers.customer_id = orders.customer_id
	JOIN sales ON orders.order_id = sales.order_id
	JOIN products ON sales.product_id = products.product_id
	GROUP BY state, product_name
)
SELECT "state", "product_name", "total_sales"
FROM most_popular_products_by_state
WHERE rank <= 3
ORDER BY "state", rank

/*
The information retrieved from this set of queries is catered to the locations where the product
is being delivered. Sales volume and delivery time can help management decide on building warehouses
to hold products near the states with the highest sales rate and improve delivery time for high-priority reas.
*/

-- Product related query

-- checking what each products total sales counts are
SELECT "products".product_name, "products".product_type, SUM("sales".quantity) AS Num_sales
FROM "products"
JOIN "sales" 
ON products.product_id = sales.product_id
GROUP BY "products".product_type, "products".product_name
ORDER BY Num_sales DESC;

-- Looking at the products that have not produced any sales
SELECT "products".product_name, "products".product_type
FROM "products"
LEFT JOIN sales ON products.product_id = sales.product_id
WHERE sales.product_id IS NULL;

-- Checking what sizes are most sold for each product type
SELECT "products".product_type, "products".size, SUM("sales".quantity) as total_sales
FROM "products"
JOIN sales ON products.product_id = sales.product_id
GROUP BY products.product_type, products.size
ORDER BY total_sales DESC;

-- Checking sum of products have sold in the last month and comparing them to inventory count
WITH last_month_sales AS (
	SELECT product_id, SUM(quantity) as total_sales
	FROM orders
	JOIN sales on orders.order_id = sales.order_id
	WHERE order_date >= date_trunc('month', (SELECT max(order_date) from orders)) - INTERVAL '1 month'
	GROUP BY product_id
)
SELECT products.product_type, products.product_name, products.size,
	last_month_sales.total_sales,
	products.quantity as inventory_count
FROM products
LEFT JOIN last_month_sales ON products.product_id = last_month_sales.product_id
WHERE total_sales IS NOT NULL
ORDER BY total_sales DESC;

--Checking what colors are most popular
SELECT "products".product_type, "products".colour, SUM("sales".quantity) as total_sales
FROM "products"
JOIN sales ON products.product_id = sales.product_id
GROUP BY products.product_type, products.colour
ORDER BY total_sales DESC;

-- Checking for the 5 most expensive products
SELECT DISTINCT(product_name),product_type, price
FROM products
ORDER BY price DESC
LIMIT 5

-- Checking the price range of each product type
SELECT product_type, MIN(price) as minimum_tag, MAX(price) as Maximum_tag
FROM products
GROUP BY product_type;

/*
The information retrieved from this set of queries is focused on the product carried by the supplier.
Using the results generated by the queries product are checked and ranked from high to low sales volume,
as well as products that may need to be discontinued. As well as diving deeper into product specifics
such as size and colors that are most popular. 
*/


-- Customer related queries:

-- Number of orders, quantity sold, and spending for the top 10 customers with highest quantity count
SELECT "orders".customer_id, COUNT(DISTINCT("orders".order_id)) as number_of_orders,
SUM("sales".quantity) as total_quantity, SUM("sales".total_price) as total_spending
FROM "orders"
JOIN sales ON orders.order_id = sales.order_id
GROUP BY "orders".customer_id
ORDER BY total_quantity DESC
LIMIT 10;

-- Customers that have not ordered an item
SELECT "customers".customer_name
FROM "customers"
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.customer_id IS NULL;

-- Overall Average average time spend on deliveries
SELECT  AVG("orders".delivery_date - "orders".order_date) as avg_delivery_time
FROM "orders"
WHERE "orders".delivery_date IS NOT NULL;

-- Average delivery time for each customer
SELECT  "orders".customer_id, AVG("orders".delivery_date - "orders".order_date) as avg_delivery_time,
"customers".city, "customers".state
FROM "orders"
JOIN customers ON orders.customer_id = customers.customer_id
WHERE "orders".delivery_date IS NOT NULL
GROUP BY "orders".customer_id, "customers".city, "customers".state
ORDER BY avg_delivery_time DESC;


-- Checking number of orders placed by each gender
SELECT "customers".gender, COUNT("orders".order_id) as orders_placed
FROM "customers"
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY "customers".gender
ORDER BY orders_placed DESC;

-- Checking what each age range contributes to ordering
SELECT FLOOR("customers".age / 10) * 10 AS age_range, COUNT("orders".order_id) AS total_orders 
FROM "customers" 
LEFT JOIN orders ON customers.customer_id = orders.customer_id 
GROUP BY age_range 
ORDER BY age_range;

/*
The information extracted in this set of queries is catered around understanding the customer base more.
From most engaging customers to those who have not made any purchases in the company.
Investigating delivery time was another important aspect as it pertains to customer satisfaction
with the company. Finally understanding the customer demographic of the company.
*/

