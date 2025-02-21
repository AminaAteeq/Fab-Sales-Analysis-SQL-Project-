-- To check out the the database internal schema information.
select * from INFORMATION_SCHEMA.TABLES
USE DataWarehouseAnalytics;
GO
-- To check out the columns from the specifc table from the schema.
select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='dim_customers'

-- To check out the coutry from where our customers are
select distinct country from gold.dim_customers

-- Explore all the Category "The major Divisions"
select distinct category, subcategory, product_name from gold.dim_products
order by 1,2,3

-- find out the min order date and the max order date and the years span between them
select
min(order_date) as first_order,
max(order_date) as Last_order,
DATEDIFF(YEAR, min(order_date), max(order_date)) as  order_range
from gold.fact_sales

--find the the youngest and the oldest brithday
select
min(birthdate) as oldest_birth,
DATEDIFF(YEAR, min(birthdate), getdate()) as oldest,
max(birthdate) as yougest_birth,
DATEDIFF(YEAR, max(birthdate), getdate()) as youngest
from gold.dim_customers

-- find out the total sales
select sum(sales_amount) as total_sales from gold.fact_sales

--  find how many items are sold
select sum(quantity) as total_quantity from gold.fact_sales

-- find the average selling price
select avg(price) as avg_price from gold.fact_sales

-- find out the total numbers of orders
select count(distinct order_number) as total_orders from gold.fact_sales

-- find out the total numbers of customers
select count(customer_key) as total_products from gold.dim_customers

-- find out the total number of customers that has place an orders
select count(distinct customer_key) as total_products from gold.fact_sales

-- a overview of report which shows all the key metrics of business

select 'Total Sales' as measure_name, sum(sales_amount) as measure_value from gold.fact_sales
union all
select 'Total Quantity' as measure_name, sum(quantity) as measure_value from gold.fact_sales
union all
select 'Avg Price' as measure_name, avg(price) as measure_value from gold.fact_sales
union all
select 'Total Orders' as measure_name, count(distinct order_number) as measure_value from gold.fact_sales
union all
select 'Total Number of Orders' as measure_name, count(distinct order_number) as measure_value from gold.fact_sales
union all
select 'Total No of Products' as measure_name, count(product_name) as measure_value from gold.dim_products
union all
select 'Total No of customers' as measure_name ,count(distinct customer_key) as measure_value from gold.fact_sales

-- find total customers by countries
select country, count(customer_key) as total_customers 
from gold.dim_customers
group by country
order by total_customers desc

-- find total customers by gender
select gender, count(customer_key) as total_customers 
from gold.dim_customers
group by gender
order by total_customers desc

-- find total products by category
select category, count(distinct product_key) as total_products
from gold.dim_products
group by category
order by total_products desc

-- what is the average cost in each cateogry?
select category, avg(cost) as avg_cost
from gold.dim_products
group by category
order by avg_cost desc

-- what is the total revenue generated for each category?
select p.category,
sum(sales_amount) as total_revenue
from gold.fact_sales f 
left join gold.dim_products p
on p.product_key=f.product_key
group by p.category
order by total_revenue desc

-- what is the total revenue generated for each customers?
select p.customer_key,
p.first_name,
p.last_name,
sum(sales_amount) as total_revenue
from gold.fact_sales f 
left join gold.dim_customers p
on p.customer_key=f.customer_key
group by p.customer_key,
p.first_name,
p.last_name
order by total_revenue desc

-- what is the distribution of sold items across countries?
select p.country,
sum(f.quantity) as total_sold_items
from gold.fact_sales f 
left join gold.dim_customers p
on p.customer_key=f.customer_key
group by p.country
order by total_sold_items desc

-- which 5 products generate the highest revenue?
select top 5
p.product_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f 
left join gold.dim_products p
on p.product_key=f.product_key
group by p.product_name
order by total_revenue desc

-- with window function
select *
from (
	select 
	p.product_name,
	sum(f.sales_amount) as total_revenue,
	row_number() over (order by sum(f.sales_amount)desc) as rank_products
	from gold.fact_sales f 
	left join gold.dim_products p
	on p.product_key=f.product_key
	group by p.product_name)t
where rank_products<=5

-- which 5 worst-performing products in terms of sales?
select top 5
p.product_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f 
left join gold.dim_products p
on p.product_key=f.product_key
group by p.product_name
order by total_revenue

-- the 3 customers with fewest order placed
select top 3
p.customer_key,
p.first_name,
p.last_name,
count(distinct order_number) as total_orders
from gold.fact_sales f 
left join gold.dim_customers p
on p.customer_key=f.customer_key
group by p.customer_key,
p.first_name,
p.last_name
order by total_orders

-- find the top 10 customers who have generated the highest revenue

select top 10
p.customer_key,
p.first_name,
p.last_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f 
left join gold.dim_customers p
on p.customer_key=f.customer_key
group by p.customer_key,
p.first_name,
p.last_name
order by total_revenue