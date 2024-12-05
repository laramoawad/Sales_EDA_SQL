--Sales Database 
-------------------------Beginner-Intermediate Level Questions------------------------------
Create Table Customers (
customer_id SERIAL primary key, --When you define a column as SERIAL, PostgreSQL automatically generates a unique integer value for each new row inserted into the table
first_name varchar(50) not null, 
last_name varchar(50) not null, 
email varchar(50) unique not null, 
country varchar (50) not null
); 

Insert into Customers(first_name, last_name, email, country) values
('John', 'Doe', 'john.doe@example.com', 'USA'), 
('Jane', 'Smith','jane.smith@example.com', 'Canada'), 
('Bob', 'Johnson', 'bob.johnson@example.com', 'UK'),
('Alice', 'Brown', 'alice.brown@example.com', 'Australia'),
('Charlie', 'Davis', 'charlie.davis@example.com', 'USA');

select*
from customers;

--Create Table Products 

Create Table Products (
product_id int primary key, 
product_name varchar(100) not null,
category varchar(100),
price numeric(10,2) not null, --numeric cuz da can be decimal and i want up to 2 decimal points
stock_quantity int not null); 	

Insert into products values ('101','Laptop', 'Electronics', 1000.00, 50),
    ('102','Smartphone', 'Electronics', 700.00, 100),
    ('103','Desk Chair', 'Furniture', 150.00, 200),
    ('104','Coffee Maker', 'Appliances', 80.00, 75),
    ('105','Water Bottle', 'Sporting Goods', 20.00, 300);

select*
from products;

--Vreate table orders 

Create table Orders (
order_id serial primary key, 
customer_id int references customers (customer_id),
product_id int references products (product_id), 
order_date date not null, 
quantity int not null
); 

Insert into Orders values (1001, 1, 101, '2024-01-15', 1),
    (1002, 1, 105, '2024-01-18', 3),
    (1003, 2, 103, '2024-02-10', 2),
    (1004, 3, 104, '2024-02-15', 1),
    (1005, 4, 102, '2024-03-05', 1),
    (1006, 5, 105, '2024-03-12', 5),
    (1007, 2, 101, '2024-04-20', 1),
    (1008, 1, 102, '2024-04-22', 1),
    (1009, 3, 101, '2024-05-01', 1),
    (1010, 4, 105, '2024-05-03', 2);

select * 
from orders; 


--Retrieve the first name, last name, and email of all customers.

select first_name, last_name, email
from customers; 

-- Find all orders where the quantity ordered is greater than 2.
select * 
from orders
where quantity > 2;


--Write a query to list all orders with the customer's first name, product name, order date, and quantity.
select cus.first_name, cus.last_name, prod.product_name, ord.order_date, ord.quantity 
from orders as ord
join customers as cus on cus.customer_id = ord.customer_id
join products as prod on prod.product_id=ord.product_id;


--Calculate the total revenue generated from all orders.
select * 
from orders; 

with cte1 as (select prod.price, ord.order_date, prod.product_id, ord.quantity
from products as prod 
join orders as ord on prod.product_id= ord.product_id)
select sum(price*quantity) as total_revenue
from cte1
;
 --OR DO IT THIS WAY 
SELECT SUM(prod.price * ord.quantity) AS total_revenue
FROM products AS prod
JOIN orders AS ord ON prod.product_id = ord.product_id;


--List the total number of orders placed by each customer.

select customer_id, count (order_id) as number_of_orders
from orders
group by customer_id
order by customer_id;

--Retrieve all products sorted by price in descending order.

select product_name, price 
from products 
order by price desc; 


--Find the product that has been ordered the most.

select prod.product_name, sum(quantity) as total_quant
from products as prod
join orders as ord on ord.product_id=prod.product_id
group by product_name
order by total_quant desc
limit 1; 

 

--Write a query to find all orders placed in the month of April 2024.

--This doesnt work becuase The LIKE operator is generally used with patterns for string matching. 
--For date comparisons, it's more appropriate to use date functions or range conditions.
select * 
from orders
where order_date like '2024-04%'; 

--hence do this 

select * 
from orders 
where order_date >='2024-04-01' And order_date < '2024-05-01'

--Update the stock quantity of the product with ID 105 by subtracting the total quantity ordered for this product.

select sum(quantity)
from orders 
where product_id=105; 

--i took the above query and put it as subquery in the below 
--why use coalesce:  Ensures that if there are no orders for the product, the subquery returns 0 instead of NULL.
update products 
set stock_quantity = stock_quantity - (select COALESCE(SUM(quantity), 0)
from orders 
where product_id=105)
where product_id=105;

select * 
from products; 


--Delete all orders made by the customer with the email jane.smith@example.com.

select customer_id, email 
from customers 
where email = 'jane.smith@example.com';
--we find out this is customer_id =2  

delete from orders 
where customer_id=2;

select * 
from orders 
where customer_id=2;  
--this returns nothign so we're good 

select * 
from orders 
--double checking 

--Id like to bring in the orders for customer_id 2 back again 

select * 
from orders;

insert into orders values (1003,2,103,'2024-02-10',2),(1007,2,101,'2024-04-20',1);

--Id like to return back the stock_quantity of product 105 to 300 again 

update products 
set stock_quantity = 300
where product_id = 105; 

select*
	from products; 


--------------------------------Intermediate-Advanced level questions-------------------------------------


--Calculate the running total of the revenue generated by each customer, ordered by the order date.
--Hint: running totals need window functions
select ord.customer_id, ord.order_date, 
	(price*quantity) as revenue, 
	sum(price*quantity)over(partition by customer_id order by order_date) as running_total
from products as prod
join orders as ord on prod.product_id=ord.product_id
;
--here we used sum window with partitioning and order by 


--Calculate the running total of the revenue generated in april ordered by the order date.
select customer_id, order_date, (price*quantity)as revenue, sum(price*quantity)over(order by order_date)
from products as prod
join orders as ord on prod.product_id=ord.product_id
where order_date >= '2024-01-01' and order_date <= '2024-02-01'; 


-- Write a query to find the customer who has placed the most orders and the total value of those orders.

with cte as (
select customer_id, count(order_id) as orders_placed, sum(price*quantity) as revenue
from orders as ord
join products as prod on prod.product_id=ord.product_id
group by customer_id
)
select cust.first_name, cust.last_name, cte.*
from customers as cust
join cte on cust.customer_id=cte.customer_id 
order by orders_placed desc
limit 1;	
--Placing ORDER BY and LIMIT in the outer query ensures that your query logic is clear: 
--you first aggregate and then sort/filter. This separation helps in understanding what each part of the query is doing.



--Identify customers who have purchased more than one product on the same order date.

select customer_id, order_date, count (distinct product_id)
from orders
group by customer_id, order_date
having count (distinct product_id) >1
order by customer_id, order_date;
--it will return 0 as there were no customers who have purchased more than one product on the same order date



--For each product, calculate the percentage of the total quantity sold that it represents.

--always add the coalesce at end cuz if null values it handles them and puts makanhom what u want, here i put 0
select prod.product_name, prod.product_id, prod.stock_quantity,  
	COALESCE(SUM(ord.quantity), 0) AS total_quantity_sold, 
	ROUND((COALESCE(SUM(ord.quantity), 0) * 100.0 / prod.stock_quantity), 2) AS percentage_of_total_sold
from products as prod
left join orders as ord on prod.product_id = ord.product_id
group by prod.product_name, prod.product_id,prod.stock_quantity
order by product_id;

--or can do case statement too to handle null values, same thing 


SELECT prod.product_name, prod.product_id, prod.stock_quantity, SUM(ord.quantity) AS total_quantity_sold,
	ROUND(
        (CASE 
            WHEN SUM(ord.quantity) IS NULL THEN 0 
            ELSE SUM(ord.quantity) 
         END * 100.0 / prod.stock_quantity), 
        2) AS percentage_of_total_sold
FROM products AS prod
LEFT JOIN orders AS ord ON prod.product_id = ord.product_id
GROUP BY prod.product_name, prod.product_id, prod.stock_quantity
order by product_id;
;


--Create a report that shows the total quantity of each product sold per month in 2024.

select ord.product_id, prod.product_name, sum(quantity) as total_quantity,
Extract(month from order_date) AS month_
from orders as ord
join products as prod 
on ord.product_id=prod.product_id
group by ord.product_id, prod.product_name, Extract(month from order_date)
order by month_; 


-- Find the top 3 products with the highest total revenue generated. Use GROUP BY and ORDER BY with a limit.
select prod.product_name, ord.product_id, sum(quantity*price) as revenue
from orders as ord
join products as prod 
on prod. product_id=ord.product_id
group by prod.product_name, ord.product_id
order by revenue desc
limit 3;


-- Assume the Customers table has an additional column preferences storing data in JSON format. Write a query to extract customers who prefer a specific category of products.
--lets say we want to extract customers interested in electronics 

alter table customers 
add column Preferences Json; 

select * from customers ; 

update customers
set preferences = '{"preferred_categories": ["Electronics", "Furniture"]}'
where customer_id = 1;

update customers 
set preferences = '{"preferred_categories": ["Appliances"]}'
where customer_id=2; 

update customers 
set preferences = '{"preferred_categories": ["Sporting Goods"]}'
where customer_id=3; 

UPDATE Customers
SET preferences = '{"preferred_categories": ["Electronics", "Sporting Goods"]}'
WHERE customer_id = 4;

UPDATE Customers
SET preferences = '{"preferred_categories": ["Electronics", "Furniture", "Sporting Goods"]}'
WHERE customer_id = 5;

/* DOES NOT WORK
SELECT customer_id,first_name,last_name, email,country, preferences 
from customers 
where preferences -> 'preferred_categories' ? 'Electronics'; */

--FIXED IT 

ALTER TABLE Customers
ALTER COLUMN preferences TYPE JSONB USING preferences::JSONB;

SELECT *
FROM Customers
WHERE preferences -> 'preferred_categories' @> '["Electronics"]';

--preferences -> 'preferred_categories': Extracts the preferred_categories array from the JSON.
--@> '["Electronics"]': Checks if the JSON array contains the value "Electronics".


--Write a query to find the average order value for each customer who has ordered more than once.
with cte as 
(
select customer_id
from orders
group by customer_id
having count(*) >1
), orderVal as
(
select ord.customer_id, sum(price * quantity) as total_order_val
from orders as ord
join products as prod on prod.product_id = ord.product_id
group by ord.customer_id, ord.order_id  
--need to add order id for it to group by that there are 2 or more order ids for the same customer this 
--later imp so when u get avg it takes into consideration all order IDS and divides it by number of orders made for that customer
)
select c.customer_id, round(avg(ov.total_order_val),2) as avg_of_total_order
from cte as c
join orderVal as ov on c.customer_id = ov.customer_id
GROUP BY c.customer_id
order by c.customer_id;


--Write a query that retrieves the total revenue generated per product category

select coalesce(prod.category, 'All categories') as prod_category, 
	coalesce(prod.product_id::Text, 'Total for category') as product_id, sum(quantity* price) as revenue, 
	CASE
        WHEN GROUPING(prod.category) = 1 THEN 'Grand Total'
        WHEN GROUPING(prod.product_id) = 1 THEN 'Subtotal by Category'
        ELSE 'Detailed'
    END AS aggregation_level
from orders as ord
join products as prod on prod.product_id = ord.product_id
group by rollup (prod.category, prod.product_id)
order by prod.category nulls first, prod.product_id nulls first; 


select * from products ; 

select * from customers ; 

select * from orders ; 

--create a templorary table for electronic products only 

create temp table electronics_only as 
select * 
from products 
where category ilike 'elect%'

--ilike considers capital and non-capital 
	
select * 
from electronics_only; 
