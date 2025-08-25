--1. **Create View: `vw_recent_orders_30d`**
--   - View of orders placed in the **last 30 days** from `CURRENT_DATE`, excluding `cancelled`.
--   - Columns: order_id, customer_id, order_date, status, order_total (sum of items).

-- i have changed the interval date as the time of order date exceed more than 30 days .

create or replace view vw_recent_orders_30d as
select o.order_id, o.customer_id, o.order_date, o.status, 
sum(ot.quantity * ot.unit_price) as order_total
from orders as o
join order_items as ot on o.order_id = ot.order_id
where o.order_date >= current_date - interval '90 days' and o.status != 'cancelled'
group by o.order_id, o.customer_id, o.order_date, o.status;

select * from vw_recent_orders_30d ;


--2. **Products Never Ordered**
--   - Using a subquery, list products that **never** appear in `order_items`.

select product_name   from products as p
left join order_items as ot on p.product_id = ot.product_id  
where p.product_id  not in (select product_id from order_items )
;

--
--3. **Top Category by City**
--   - For each `city`, find the **single category** with the highest total revenue.
-- Use an inner subquery or a view plus a filter on rank.
--
select city,
sum(p.amount) as total_revenue ,
rank() over ( order by sum(p.amount) desc)
from customers c 
inner join orders o  on c.customer_id = o.customer_id 
inner join payments p  on o.order_id  = p.order_id 
group by  c.city  
; 


--4. **Customers Without Delivered Orders**
--   - Using `NOT EXISTS`, list customers who have **no orders** with status `delivered`.

select full_name  from customers c 
where  not exists (select status from orders o where c.customer_id = o.customer_id and status = 'delivered' )
;
