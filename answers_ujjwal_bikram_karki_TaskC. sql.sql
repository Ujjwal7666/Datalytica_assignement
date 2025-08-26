--1. **Scalar Function: `fn_customer_lifetime_value(customer_id)`**
--    - Return total **paid** amount for the customer's delivered/shipped/placed (non-cancelled) orders.
create or replace function fn_customer_lifetime_value (p_customer_id int)
returns numeric
language sql
as $$ 
	select sum(amount)  from  payments p 
join orders o on p.order_id =o.order_id 
where o.customer_id = p_customer_id  and o.status in ('delivered','shipped' , 'placed')
;
$$

select fn_customer_lifetime_value(5);


--2. **Table Function: `fn_recent_orders(p_days INT)`**
--    - Return `order_id, customer_id, order_date, status, order_total` for orders 
--in the last `p_days` days.

create or replace function fn_recent_orders(p_days int)
returns table(
	order_id int, customer_id int, order_date date, status text, order_total numeric
)
language sql 
as $$ 
select o.order_id, o.customer_id, o.order_date, o.status, 
sum(ot.quantity * ot.unit_price) as order_total
from orders as o
join order_items as ot on o.order_id = ot.order_id
where o.order_date >= current_date - (p_days || ' days')::interval
group by o.order_id, o.customer_id, o.order_date, o.status;
$$

select * from fn_recent_orders(100);

--3. **Utility Function: `fn_title_case_city(text)`**
--    - Return city name with first letter of each word capitalized 
--(hint: split/upper/lower or use `initcap()` in PostgreSQL).

create or replace function fn_title_case_city( city_name text)
returns text 
language sql
as $$ 
	select initcap(city_name);
$$

select fn_title_case_city('rammechhap metropolitan city is NIce to meet');
