--Task A Window Function
--1. **Monthly Customer Rank by Spend**
--   - For each month (based on `order_date`), rank customers by **total order value** in that month using `RANK()`.
--   - Output: month (YYYY-MM), customer_id, total_monthly_spend, rank_in_month.

select  To_char (order_date, 'YYYY-MM') as order_month,c.customer_id,  
sum (p.amount) as total_monthly_spend,  
Rank() over(
PARTITION BY TO_CHAR(o.order_date, 'YYYY-MM')
order by sum (p.amount)desc) 
from customers as c
inner join orders as o on c.customer_id = o.customer_id
inner join payments as p on o.order_id = p.order_id 
group by c.customer_id , order_month 
;


--
---2. **Share of Basket per Item**
--   - For each order, compute each item's **revenue share** in that order:
--     `item_revenue / order_total` using `SUM() OVER (PARTITION BY order_id)`.

select 
order_id, 
quantity * unit_price as item_revenue ,
SUM(quantity * unit_price) over (partition by order_id) as order_total,
 (quantity * unit_price) /
SUM(quantity * unit_price) over (partition by order_id) as revenue_share
from order_items;

;
--
--3. **Time Between Orders (per Customer)**
--   - Show days since the **previous order** for each customer using `LAG(order_date)` and `AGE()`.
select customer_id ,
order_date,
LAG(order_date) over (partition by customer_id order by order_date) as previous_order_date,
AGE(order_date, LAG(order_date) over (partition by customer_id order by order_date)) as days_since_pev_order
from orders;
--
--4. **Product Revenue Quartiles**
--   - Compute total revenue per product and assign **quartiles** using `NTILE(4)` over total revenue.
select  
p.product_name,
sum (o.quantity * o.unit_price)  as total_revenue_per_prodcut,
NTILE(4) OVER (ORDER BY sum(o.quantity * o.unit_price) )
from products as p
inner join order_items o on p.product_id  = o.product_id 
group by  p.product_name 

;



--5. **First and Last Purchase Category per Customer**
--   - For each customer, show the **first** and **most recent** 
--product category they've bought using `FIRST_VALUE` and `LAST_VALUE` over `order_date`.

select distinct c.full_name,
first_value(p.category ) over( partition by c.customer_id order by o.order_date ) as first_product_category,
last_value(p.category ) over( partition by c.customer_id order by o.order_date  
rows between unbounded preceding and unbounded following) as last_product_category
from products as p
join order_items as ot on p.product_id  = ot.product_id
join orders as o on ot.order_id = o.order_id 
join customers  as c on o.customer_id = c.customer_id
;
