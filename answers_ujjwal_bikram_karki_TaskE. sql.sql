
--1. **Average Order Value by City (Delivered Only)**
--    - Output: city, avg_order_value, delivered_orders_count. 
--Order by `avg_order_value` desc. Use `HAVING` to keep cities with at least 2 delivered orders.
select city, 
avg(quantity * unit_price) as avg_order_value,
count(*) as delivered_orders_count
from customers c 
join orders o on o.customer_id = c.customer_id
join order_items ot on o.order_id = ot.order_id
where o.status = 'delivered'
group by city, o.status order by avg_order_value desc
;

select * from order_items;

--2. **Category Mix per Customer**
--    - For each customer, list categories purchased and the **count of distinct orders** per category. 
--Order by customer and count desc.

select c.full_name, p.category , 
count( distinct o.order_id ) as count_per_category
from customers c 
join orders o on o.customer_id = c.customer_id 
join order_items ot on o.order_id = ot.order_id  
join products p on p.product_id = ot.product_id 
where o.status = 'delivered'
group by c.full_name,  p.category order by c.full_name, count_per_category desc
;


--
--3. **Set Ops: Overlapping Customers**
--    - Split customers into two sets: those who bought `Electronics` and those who bought `Fitness`. Show:
--      - `UNION` of both sets,
--      - `INTERSECT` (bought both),
--      - `EXCEPT` (bought Electronics but not Fitness).

--union
select c.full_name
from customers c 
join orders o on o.customer_id = c.customer_id 
join order_items ot on o.order_id = ot.order_id  
join products p on p.product_id = ot.product_id 
where p.category = 'Electronics'
group by c.full_name , p.category 

union

select c.full_name
from customers c 
join orders o on o.customer_id = c.customer_id 
join order_items ot on o.order_id = ot.order_id  
join products p on p.product_id = ot.product_id 
where p.category = 'Fitness'
group by c.full_name , p.category 
;

-- intersect

select c.full_name
from customers c 
join orders o on o.customer_id = c.customer_id 
join order_items ot on o.order_id = ot.order_id  
join products p on p.product_id = ot.product_id 
where p.category = 'Electronics'
group by c.full_name

intersect

select c.full_name 
from customers c 
join orders o on o.customer_id = c.customer_id 
join order_items ot on o.order_id = ot.order_id  
join products p on p.product_id = ot.product_id 
where p.category = 'Fitness'
group by c.full_name 
;

--except

select c.full_name
from customers c 
join orders o on o.customer_id = c.customer_id 
join order_items ot on o.order_id = ot.order_id  
join products p on p.product_id = ot.product_id 
where p.category = 'Electronics'
group by c.full_name

except

select c.full_name 
from customers c 
join orders o on o.customer_id = c.customer_id 
join order_items ot on o.order_id = ot.order_id  
join products p on p.product_id = ot.product_id 
where p.category = 'Fitness'
group by c.full_name 
;