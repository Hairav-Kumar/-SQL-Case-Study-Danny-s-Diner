create database sql_project;
use sql_project;
CREATE TABLE sales(customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');


CREATE TABLE menu
(product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');


CREATE TABLE members(customer_id VARCHAR(1),
join_date DATE);

INSERT INTO members(customer_id, join_date)
VALUES
  ('A', '2021-01-07'),('B', '2021-01-09');
  
-- Q1 What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(m.price) as total_amount from sales as s join menu as 
	m on s.product_id = m.product_id 
group by s.customer_id;

-- Q2 How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date) as customer_visits from sales group by
	customer_id order by customer_visits desc;

-- Q3 What was the first item from the menu purchased by each customer?
with cte as (select customer_id,product_id 
	from(select *,dense_rank() over(partition by customer_id order by order_date asc) 
    as rnk from sales) sal where rnk=1)
select c.customer_id,m.product_name as first_product_ordered from cte as c join menu as m on c.product_id=m.product_id;

-- Q4 What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name,count(*) as Purchase_count from sales as s 
	join menu as m on s.product_id=m.product_id group by m.product_name 
order by Purchase_count desc;

-- Q5 Which item was the most popular for each customer?
with cte as (
select customer_id,product_id, dense_rank() over(partition by customer_id
	order by count(*) desc) as rnk from sales 
group by customer_id,product_id)
select c.customer_id,m.product_name as popular_food from cte as c join menu as m on 
	c.product_id=m.product_id where rnk=1 order by c.customer_id;

-- Q6 Which item was purchased first by the customer after they became a member?
with cte as (select s.customer_id,s.order_date as date_after_joining,s.product_id from sales as s 
	join members as m on s.customer_id=m.customer_id 
where s.order_date>=m.join_date),
cte2 as(select customer_id , product_id from (select *,row_number() over(partition by 
	customer_id order by date_after_joining asc) as rnk from cte) sal where rnk=1)
select cte2.customer_id,m.product_name from cte2 join menu as m on cte2.product_id=m.product_id order by cte2.customer_id;

-- Q7 What is the total items and amount spent for each member before they became a member?
with cte as (select s.customer_id,s.product_id from sales as s 
	join members as m on s.customer_id=m.customer_id where s.order_date<m.join_date)
select c.customer_id,sum(m.price) as amount_spent from cte as c join menu as m on c.product_id=m.product_id group by c.customer_id;

-- Q8 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
  select s.customer_id,sum(case when m.product_name="sushi" then price*20 else price*10 end) as 
	points from sales as s join menu as m on s.product_id=m.product_id
group by s.customer_id;

-- Q9 Get the total sales, grouped by year and month, from the sales dataset?

select year(s.order_date) as year,Month(s.order_date) as month,sum(price) as 
	total from sales as s join menu as m on s.product_id=m.product_id 
group by year(s.order_date),Month(s.order_date) order by total desc;

  
  
  
  
  
  
  