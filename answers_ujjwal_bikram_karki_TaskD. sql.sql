--1. **`sp_apply_category_discount(p_category TEXT, p_percent NUMERIC)`**
--    - Reduce `unit_price` of **active** products in a category by `p_percent`
--    (e.g., 10 = 10%). Prevent negative or zero prices using a `CHECK` at update time.
create or replace procedure sp_apply_category_discount(
    p_category text, 
    p_percent numeric
)
language plpgsql
as $$
begin
   
    update products
    set unit_price = greatest(unit_price * (1 - p_percent / 100), 0.00)
    where category = p_category
      and active = true;
end;
$$;

-- Apply 10% discount to Home category
call sp_apply_category_discount('Home', 10);


--2. **`sp_cancel_order(p_order_id INT)`**
--    - Set order `status` to `cancelled` **only if** it is not already `delivered`.
--    - (Optional) Delete unpaid `payments` if any exist for that order 
--    (there shouldn’t be, but handle defensively).

create or replace procedure sp_cancel_order(p_order_id int)
language plpgsql
as $$
begin
    
	update orders 
	set status = 'cancelled'
	where order_id = p_order_id and status != 'delivered';

END;
$$;

call sp_cancel_order(12);

select * from orders;
--
--3. **`sp_reprice_stale_products(p_days INT, p_increase NUMERIC)`**
--    - For products **not ordered** in the last `p_days`, increase `unit_price` by `p_increase` percent.
create or replace procedure sp_reprice_stale_products(p_days int, p_increase numeric)
language plpgsql
as $$
begin
    update products p
    set unit_price = unit_price * (1 + p_increase / 100)
    where not exists (
        select 1
        from order_items oi
        join orders o on oi.order_id = o.order_id
        where oi.product_id = p.product_id
          and o.order_date >= current_date - (p_days || ' days')::interval
    );
end;
$$;

call sp_reprice_stale_products(80, 10);

select * from products;


