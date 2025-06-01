CREATE DATABASE ecommerce_db;
USE ecommerce_db;
CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  city VARCHAR(50),
  country VARCHAR(50),
  created_at DATETIME
);
-- Products table
CREATE TABLE products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(50),
  price DECIMAL(10,2),
  stock_quantity INT
);

-- Orders table
CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATETIME,
  total_amount DECIMAL(10,2),
  status VARCHAR(20),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items table
CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Payments table
CREATE TABLE payments (
  payment_id INT PRIMARY KEY,
  order_id INT,
  payment_method VARCHAR(50),
  payment_date DATETIME,
  amount DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
select * from order_items;

-- (Group By)
 -- Q: Find the number of orders placed by each customer.

SELECT customer_id, COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id;

-- Q: Get the total quantity sold per product.


SELECT product_id, SUM(quantity) AS total_sold
FROM order_items
GROUP BY product_id;

-- (Join)

-- Q: List all customers along with their city and the total amount they spent 
-- (only include customers who placed at least one order).


SELECT c.customer_id, c.first_name, c.city, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- Q: Show each order with customer name and total order amount.

SELECT o.order_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- Q: List all products that were never ordered.


SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;

-- (Subquery)
-- Q: Find customers who placed at least one order of amount greater than the average order amount.


SELECT customer_id
FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders);

-- Q: Get all products with a price higher than the average price.

SELECT product_id, product_name
FROM products
WHERE price > (SELECT AVG(price) FROM products);


-- (Window Function)
-- Q: Show each order with its customer's total number of orders (using window function).


SELECT order_id, customer_id, 
       COUNT(*) OVER (PARTITION BY customer_id) AS total_orders_by_customer
FROM orders;

-- Q: Display each product’s sales rank based on total quantity sold.

SELECT product_id, 
       SUM(quantity) AS total_sold,
       RANK() OVER (ORDER BY SUM(quantity) DESC) AS sales_rank
FROM order_items
GROUP BY product_id;


-- (Correlated Subquery)

-- Q: List all orders where the total amount is greater than that customer's average order amount.

SELECT o.order_id, o.customer_id, o.total_amount
FROM orders o
WHERE o.total_amount > (
    SELECT AVG(o2.total_amount)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
);



