-- Retrieve each restaurant_id, its name, and the number of orders placed for it (join Restaurants → Orders).

select r.restaurant_id, name, count(order_id)
from Restaurants r
inner join Orders o
on r.restaurant_id = o.restaurant_id
group by restaurant_id, name;

-- Retrieve each user_id, name, and the total amount they've paid, joining Users → Orders → Payments.

select o.user_id, name, sum(amount) as total_amount
from Orders o
inner join Payments p
on o.order_id = p.order_id
inner join Users u
on u.user_id = o.user_id
group by o.user_id, name;

-- Retrieve each order_id along with the delivery partner's name who delivered it (join Orders → Order_Delivery → Delivery_Partners).

select o.order_id, dp.name as delivery_partner_name
from Orders o
inner join Order_Delivery od
on od.order_id = o.order_id
inner join Delivery_Partners dp
on dp.partner_id = od.partner_id;

-- Retrieve each dish_id, name, and how many times it's been ordered, joining Dishes → Order_Details.

select d.dish_id, name, count(quantity) as total_order_count
from Order_Details od
inner join Dishes d
on od.dish_id = d.dish_id
group by d.dish_id, name;

-- Retrieve each restaurant_id, name, and its average rating from Reviews. Aggregation + grouping

select r.restaurant_id, name, avg(rs.rating)
from Restaurants r
inner join Reviews rs
on r.restaurant_id = rs.restaurant_id
group by restaurant_id, name;

-- Retrieve each payment_method and the total revenue collected through it, from Payments.

select payment_method, sum(amount) as total_revenue
from Payments
group by payment_method;

-- Retrieve each restaurant_id and the total discount amount given via coupons, joining Orders → Order_Coupons.

select r.restaurant_id, r.name, sum(discount_amount) as total_discount
from Orders o 
inner join Restaurants r
on r.restaurant_id = o.restaurant_id
inner join Order_Coupons oc
on o.order_id = oc.order_id
group by restaurant_id;

-- Retrieve each city and the count of restaurants in it, along with the average average_cost_for_two.

select city, count(restaurant_id), avg(average_cost_for_two)
from Restaurants
group by city;

-- Retrieve each delivery_partner_id and the average delivery time (using delivery_start... and delivery_end... timestamps in Order_Delivery).

select partner_id, round(avg(delivery_end_time - delivery_start_time), 2)as avg_delivery_time
from Order_Delivery
group by partner_id;

Multi-table, more advanced.
Retrieve the top 5 restaurants by total revenue, joining Restaurants → Orders, and using SUM(total_price).

select r.restaurant_id, name, sum(total_price) as total_revenue
from Restaurants r
inner join Orders o
on o.restaurant_id = r.restaurant_id
group by name, restaurant_id
order by total_revenue desc
limit 5;

--  Retrieve all user_ids who have never placed an order (hint: LEFT JOIN + WHERE ... IS NULL).
 
 Select u.user_id, count(distinct u.user_id, o.order_id)
 from Users u
 left join Orders o
 on o.user_id = u.user_id
 where o.user_id is null
 group by u.user_id;
 
--  select count(distinct user_id) from Users;
--   select count(distinct user_id) from Orders;

--  Retrieve each order_id, its total_price, and the final price after discount applied from Order_Coupons.
 
 select o.order_id, o.total_price, oc.discount_amount, (o.total_price - oc.discount_amount) as final_price 
 from Orders o 
 inner join Order_Coupons oc
 on oc.order_id = o.order_id;
 
 Retrieve the most frequently ordered dish per restaurant (hint: needs GROUP BY + a way to find the max per group, e.g., a subquery or window function).
 
 select dish_id, restaurant_id, name, order_count
 from 
 (select d.dish_id,
 r.name,
 d.restaurant_id, 
 count(od.order_id) as order_count, 
 row_number() over( 
 partition by d.restaurant_id
 order by count(od.order_id) desc) sd
 from Dishes d
 inner join Order_Details od
 on d.dish_id = od.dish_id
 inner join  restaurants r
 on r.restaurant_id = d.restaurant_id
 group by d.dish_id, d.restaurant_id
 ) ranked 
 where sd= 1;
 
--  Find all restaurants whose average cost for two is above the overall average. (Hint: subquery in WHERE returning a single value)
 
 select restaurant_id, name, average_cost_for_two
 from Restaurants
 where average_cost_for_two > (select avg(average_cost_for_two)
 from Restaurants);

Retrieve all dishes that have never been ordered. (Hint: LEFT JOIN + IS NULL, or NOT IN with a subquery)
 
select d.dish_id, od.order_id, d.name
from Dishes d
left join Order_Details od
on d.dish_id = od.dish_id;

select dish_id, name
from Dishes
where dish_id not in (select dish_id from Order_Details where dish_id is not null);

-- select d.dish_id, d.name
-- from Dishes d
-- left join (
-- select distinct dish_id 
-- from Order_Details ) od
-- on d.dish_id = od.dish_id
-- where d.dish_id is null;

Find the restaurant with the highest total revenue. (Hint: GROUP BY + ORDER BY + LIMIT 1, or subquery with MAX)

select restaurant_id, name, total_revenue
from (
select r.restaurant_id, r.name, sum(total_price) as total_revenue
from Restaurants r
inner join Orders o
on o.restaurant_id = r.restaurant_id
group by restaurant_id, name 
) rps
where total_revenue = (
select max(total_revenue) from (
select sum(total_price) as total_revenue
from Orders 
group by restaurant_id
) sub 
);

-- Find the restaurant with the highest total revenue. (Hint: GROUP BY + CTE window func or subquery with MAX)


with revenue_per_restaurant as (
select r.restaurant_id, r.name, sum(o.total_price) as total_revenue
from Restaurants r
inner join  Orders o
on r.restaurant_id = o.restaurant_id
group by name, restaurant_id
)
select restaurant_id, name 
from revenue_per_restaurant 
where total_revenue = (select max(total_revenue) from revenue_per_restaurant);

Retrieve all users who have placed more orders than the average number of orders per user.

select u.user_id, u.name, count(o.order_id) as order_count
from Users u
inner join Orders o
	on o.user_id = u.user_id
group by u.user_id, u.name
having count(o.order_id) > (
	select avg(order_count) 
from (
	select count(order_id)  as order_count
	from Orders 
	group by user_id
) uoc
);



 
