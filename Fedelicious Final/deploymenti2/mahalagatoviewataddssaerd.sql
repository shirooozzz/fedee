--1st Query  

CREATE VIEW Order_list
AS
SELECT 
    c.full_name,
    MIN(o.order_id) AS MinOrder,
    MAX(o.order_id) AS MaxOrder
FROM orders o
INNER JOIN customers c 
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name;


--Query 2 - 
CREATE VIEW Sold_Items
AS
SELECT 
    m.food_name, 
    SUM(oi.quantity) AS totalsold
FROM order_items oi
INNER JOIN menu_items m 
    ON oi.menu_id = m.menu_id
GROUP BY m.menu_id, m.food_name;



--Query 3 -  totaluser


CREATE View totaluser
AS
SELECT COUNT(*) AS totalcustomers
FROM customers;


--Query 4 - 

CREATE VIEW Total_Order
AS
SELECT
    o.order_type, 
    COUNT(*) AS order_count, 
    SUM(o.total_amount) AS revenue
FROM orders o
GROUP BY o.order_type;

--Query 5 - 
CREATE VIEW Total_Revenue
AS
	SELECT
payment_date,
SUM(amount) AS daily_revenue
FROM payments
GROUP BY payment_date

--Query 6 -
CREATE View AverageMenu
AS
SELECT m.menu_id, m.food_name
FROM menu_items m
JOIN (
    SELECT menu_id, SUM(quantity) AS total_qty
    FROM order_items
    GROUP BY menu_id
) item_totals 
    ON m.menu_id = item_totals.menu_id
WHERE item_totals.total_qty > (
    SELECT AVG(total_qty)
    FROM (
        SELECT SUM(quantity) AS total_qty
        FROM order_items
        GROUP BY menu_id
    ) totals_for_avg
)
AND m.menu_id IN (
    SELECT DISTINCT menu_id
    FROM order_items
);


--Query 7 - 
CREATE View DashboardStats
AS
SELECT 
    -- Total Sales
    (
        SELECT ISNULL(SUM(amount), 0)
        FROM payments
        WHERE payment_status IN (
            'Pending Verification', 
            'Ready', 
            'Delivered', 
            'Preparing', 
            'pending', 
            'Waiting for Verification',
            'Confirmed'
        )
    ) AS grand_total_sales,

    -- Total Orders
    (
        SELECT COUNT(*) 
        FROM orders
    ) AS total_orders_count,

    -- Total Customers
    (
        SELECT COUNT(*) 
        FROM customers
    ) AS total_customers_count;


--Query 8 - 

CREATE VIEW Customer_Payment
AS
SELECT
    c.full_name AS customer_name,
    SUM(p.amount) AS total_paid,
    o.total_amount AS order_total,
    CASE 
        WHEN SUM(p.amount) >= o.total_amount THEN 'Fully Paid'
        ELSE 'Initial / Partial Payment'
    END AS payment_status
FROM payments p
JOIN orders o ON p.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.full_name, o.total_amount;

--INDEX 
--1. customers: for login / checking account
CREATE UNIQUE NONCLUSTERED INDEX Idx_Customers_Email
ON customers(email); 
--EXPLANATION: To check the account faster 

-- 2. Menu items
CREATE UNIQUE NONCLUSTERED INDEX Idx_menuitems_food
ON menu_items(food_name);
--EXPLANATION: to find food items faster

 --3. categories: for category lookup
CREATE NONCLUSTERED INDEX Idx_Categories_CategoryName
ON categories(category_name);
--EXPLANATION: To check all the food categories.

--4. menu_items: for filtering menu by category
CREATE NONCLUSTERED INDEX Idx_MenuItems_CategoryId
ON menu_items(category_id);
--EXPLANATION: To check every menu from each category.



--5. orders: for viewing orders by customer
CREATE NONCLUSTERED INDEX Idx_Orders_CustomerId
ON orders(customer_id);
--EXPLANATION: To check the orders of a customer.

 --6. order_items: for getting items under one order
CREATE NONCLUSTERED INDEX Idx_OrderItems_OrderId
ON order_items(order_id);
--EXPLANATION: to get the items of an order 

--7. reservations: for viewing reservation history of a customer
CREATE NONCLUSTERED INDEX Idx_Reservations_CustomerId
ON reservations(customer_id);
--EXPLANATION: to see the customer in reservation faster and easy 

 --8. payments: for linking payment to order
CREATE NONCLUSTERED INDEX Idx_Payments_OrderId
ON payments(order_id);
--EXPLANATION: to see the payment in order easy

SELECT *
FROM customers
WHERE email = 'fulinaramarkluis@gmail.com';

ALTER TABLE menu_items
ADD is_available BIT DEFAULT 1;