
-- =====================================================
-- RETAILIQ ADVANCED MYSQL PROJECT
-- Compatible with MySQL 8.0+
-- =====================================================

DROP DATABASE IF EXISTS retailiq;
CREATE DATABASE retailiq;
USE retailiq;

-- 1. CUSTOMERS
CREATE TABLE customers (
    customer_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    city VARCHAR(100),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. CATEGORIES
CREATE TABLE categories (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- 3. PRODUCTS
CREATE TABLE products (
    product_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (unit_price >= 0),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 4. INVENTORY
CREATE TABLE inventory (
    product_id BIGINT UNSIGNED PRIMARY KEY,
    quantity_on_hand INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 10,
    CHECK (quantity_on_hand >= 0),
    CHECK (reorder_level >= 0),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 5. ORDERS
CREATE TABLE orders (
    order_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM(
        'pending','processing','completed','cancelled'
    ) NOT NULL DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_orders_date_status (order_date,status),
    INDEX idx_orders_customer_date (customer_id,order_date)
);

-- 6. ORDER ITEMS
CREATE TABLE order_items (
    order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (order_id,product_id),
    CHECK (quantity > 0),
    CHECK (unit_price >= 0),
    CHECK (discount_pct BETWEEN 0 AND 100),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_items_product_order (product_id,order_id)
);

-- 7. PAYMENTS
CREATE TABLE payments (
    payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM(
        'card','upi','net_banking','cash'
    ) NOT NULL,
    payment_status ENUM(
        'pending','successful','failed','refunded'
    ) NOT NULL DEFAULT 'pending',
    paid_at DATETIME NULL,
    CHECK (amount >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    INDEX idx_payments_order_status (order_id,payment_status)
);

-- 8. INVENTORY MOVEMENTS
CREATE TABLE inventory_movements (
    movement_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity_change INT NOT NULL,
    reason ENUM(
        'restock','sale','return','adjustment'
    ) NOT NULL,
    reference_order_id BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (reference_order_id) REFERENCES orders(order_id),
    INDEX idx_movements_product_date (product_id,created_at)
);

-- =====================================================
-- SAMPLE DATA
-- =====================================================

INSERT INTO customers
(customer_id,full_name,email,city) VALUES
(1,'Aarav Shah','aarav@example.com','Mumbai'),
(2,'Priya Patil','priya@example.com','Pune'),
(3,'Rohan Mehta','rohan@example.com','Mumbai'),
(4,'Sneha Joshi','sneha@example.com','Nashik'),
(5,'Kabir Desai','kabir@example.com','Pune'),
(6,'Anaya Kulkarni','anaya@example.com','Thane'),
(7,'Vivaan Shah','vivaan@example.com','Navi Mumbai'),
(8,'Isha Verma','isha@example.com','Panvel'),
(9,'Arjun Rao','arjun@example.com','Delhi'),
(10,'Meera Nair','meera@example.com','Bengaluru');

INSERT INTO categories VALUES
(1,'Electronics'),
(2,'Accessories'),
(3,'Home'),
(4,'Office'),
(5,'Networking');

INSERT INTO products
(product_id,category_id,sku,product_name,unit_price,active) VALUES
(1,1,'EL-001','Wireless Headphones',2500,1),
(2,1,'EL-002','Mechanical Keyboard',3200,1),
(3,1,'EL-003','USB-C Monitor',15000,1),
(4,2,'AC-001','Wireless Mouse',900,1),
(5,2,'AC-002','Laptop Stand',1200,1),
(6,3,'HM-001','Desk Lamp',1800,1),
(7,4,'OF-001','Office Chair',7500,1),
(8,4,'OF-002','Notebook Pack',350,1),
(9,5,'NT-001','WiFi Router',2800,1),
(10,1,'EL-004','Webcam',2100,1);

INSERT INTO inventory VALUES
(1,100,15),(2,60,10),(3,20,5),(4,120,20),(5,40,8),
(6,30,6),(7,15,5),(8,200,30),(9,25,8),(10,12,5);

INSERT INTO orders
(order_id,customer_id,order_date,status) VALUES
(1,1,'2026-01-05 10:00:00','completed'),
(2,2,'2026-01-10 12:30:00','completed'),
(3,1,'2026-02-03 15:00:00','completed'),
(4,3,'2026-02-15 11:15:00','completed'),
(5,4,'2026-02-20 14:00:00','cancelled'),
(6,5,'2026-03-12 16:45:00','completed'),
(7,2,'2026-03-18 09:30:00','processing'),
(8,6,'2026-04-15 13:00:00','pending'),
(9,7,'2026-04-20 10:00:00','completed'),
(10,8,'2026-05-02 11:00:00','completed'),
(11,9,'2026-05-10 12:00:00','completed'),
(12,10,'2026-05-15 14:00:00','completed'),
(13,3,'2026-06-05 15:00:00','completed'),
(14,5,'2026-06-12 16:00:00','processing'),
(15,7,'2026-06-20 17:00:00','completed');

INSERT INTO order_items
(order_id,product_id,quantity,unit_price,discount_pct) VALUES
(1,1,2,2500,0),(1,4,1,900,0),
(2,2,1,3200,5),(2,5,2,1200,0),
(3,1,1,2500,10),(3,6,1,1800,0),
(4,3,1,15000,0),(4,4,2,900,0),
(5,2,1,3200,0),(6,5,3,1200,5),
(7,1,1,2500,0),(8,4,1,900,0),
(9,7,1,7500,10),(9,8,5,350,0),
(10,9,2,2800,5),(10,4,1,900,0),
(11,10,2,2100,0),(12,6,2,1800,10),
(13,3,1,15000,5),(15,8,10,350,0);

INSERT INTO payments
(payment_id,order_id,amount,payment_method,payment_status,paid_at) VALUES
(1,1,5900,'upi','successful','2026-01-05 10:05:00'),
(2,2,5440,'card','successful','2026-01-10 12:35:00'),
(3,3,4050,'upi','successful','2026-02-03 15:05:00'),
(4,4,16800,'card','successful','2026-02-15 11:20:00'),
(5,5,3200,'card','refunded',NULL),
(6,6,3420,'net_banking','successful','2026-03-12 16:50:00'),
(7,7,2500,'upi','pending',NULL),
(8,8,900,'upi','pending',NULL),
(9,9,9450,'card','successful','2026-04-20 10:05:00'),
(10,10,6220,'upi','successful','2026-05-02 11:05:00'),
(11,11,4200,'card','successful','2026-05-10 12:05:00'),
(12,12,3240,'upi','successful','2026-05-15 14:05:00'),
(13,13,14250,'card','successful','2026-06-05 15:05:00'),
(14,14,1000,'upi','failed',NULL),
(15,15,3500,'net_banking','successful','2026-06-20 17:05:00');

INSERT INTO inventory_movements
(product_id,quantity_change,reason,created_at) VALUES
(1,100,'restock','2026-01-01 09:00:00'),
(2,60,'restock','2026-01-01 09:00:00'),
(3,20,'restock','2026-01-01 09:00:00'),
(4,120,'restock','2026-01-01 09:00:00'),
(5,40,'restock','2026-01-01 09:00:00'),
(6,30,'restock','2026-01-01 09:00:00'),
(7,15,'restock','2026-01-01 09:00:00'),
(8,200,'restock','2026-01-01 09:00:00'),
(9,25,'restock','2026-01-01 09:00:00'),
(10,12,'restock','2026-01-01 09:00:00');

-- =====================================================
-- VIEWS
-- =====================================================

CREATE VIEW vw_completed_order_details AS
SELECT
    o.order_id,o.order_date,c.customer_id,c.full_name,
    p.product_name,oi.quantity,oi.unit_price,oi.discount_pct,
    ROUND(oi.quantity*oi.unit_price*
        (1-oi.discount_pct/100),2) AS line_total
FROM orders o
JOIN customers c ON c.customer_id=o.customer_id
JOIN order_items oi ON oi.order_id=o.order_id
JOIN products p ON p.product_id=oi.product_id
WHERE o.status='completed';

CREATE VIEW vw_inventory_alerts AS
SELECT p.product_id,p.sku,p.product_name,
       i.quantity_on_hand,i.reorder_level
FROM products p
JOIN inventory i ON i.product_id=p.product_id
WHERE i.quantity_on_hand<=i.reorder_level;

-- =====================================================
-- STORED PROCEDURE
-- =====================================================

DELIMITER //

CREATE PROCEDURE sp_monthly_sales(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    IF p_start_date IS NULL OR p_end_date IS NULL
       OR p_end_date<=p_start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Invalid date range';
    END IF;

    SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
           COUNT(DISTINCT o.order_id) AS completed_orders,
           SUM(oi.quantity) AS units_sold,
           ROUND(SUM(oi.quantity*oi.unit_price*
               (1-oi.discount_pct/100)),2) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id=o.order_id
    WHERE o.status='completed'
      AND o.order_date>=p_start_date
      AND o.order_date<p_end_date
    GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
    ORDER BY sales_month;
END //

-- =====================================================
-- INVENTORY TRIGGERS
-- These apply to future order_items inserts.
-- Initial sample data was inserted before creating them.
-- =====================================================

CREATE TRIGGER trg_order_item_stock_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE v_stock INT DEFAULT NULL;

    SELECT quantity_on_hand INTO v_stock
    FROM inventory
    WHERE product_id=NEW.product_id
    FOR UPDATE;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Inventory record not found';
    END IF;

    IF v_stock<NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Insufficient stock';
    END IF;
END //

CREATE TRIGGER trg_order_item_stock_deduct
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET quantity_on_hand=quantity_on_hand-NEW.quantity
    WHERE product_id=NEW.product_id;

    INSERT INTO inventory_movements
    (product_id,quantity_change,reason,reference_order_id)
    VALUES (NEW.product_id,-NEW.quantity,'sale',NEW.order_id);
END //

DELIMITER ;

-- =====================================================
-- ADVANCED ANALYTICS 1: MONTHLY REVENUE AND GROWTH
-- =====================================================

WITH monthly_sales AS (
    SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
           SUM(oi.quantity*oi.unit_price*
               (1-oi.discount_pct/100)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id=o.order_id
    WHERE o.status='completed'
    GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
),
sales_previous AS (
    SELECT sales_month,revenue,
           LAG(revenue) OVER(ORDER BY sales_month) AS prev_revenue
    FROM monthly_sales
)
SELECT sales_month,ROUND(revenue,2) AS revenue,
       ROUND(prev_revenue,2) AS previous_revenue,
       ROUND(100*(revenue-prev_revenue)/
             NULLIF(prev_revenue,0),2) AS growth_pct
FROM sales_previous
ORDER BY sales_month;

-- =====================================================
-- ADVANCED ANALYTICS 2: TOP PRODUCTS BY CATEGORY
-- =====================================================

WITH product_sales AS (
    SELECT c.category_name,p.product_id,p.product_name,
           SUM(oi.quantity) AS units_sold,
           SUM(oi.quantity*oi.unit_price*
               (1-oi.discount_pct/100)) AS revenue
    FROM categories c
    JOIN products p ON p.category_id=c.category_id
    JOIN order_items oi ON oi.product_id=p.product_id
    JOIN orders o ON o.order_id=oi.order_id
    WHERE o.status='completed'
    GROUP BY c.category_name,p.product_id,p.product_name
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER(
               PARTITION BY category_name ORDER BY revenue DESC
           ) AS revenue_rank
    FROM product_sales
)
SELECT * FROM ranked
WHERE revenue_rank<=5
ORDER BY category_name,revenue_rank;

-- =====================================================
-- ADVANCED ANALYTICS 3: CUSTOMER LIFETIME VALUE
-- =====================================================

SELECT c.customer_id,c.full_name,
       COUNT(DISTINCT o.order_id) AS completed_orders,
       ROUND(COALESCE(SUM(oi.quantity*oi.unit_price*
           (1-oi.discount_pct/100)),0),2) AS lifetime_value
FROM customers c
LEFT JOIN orders o
    ON o.customer_id=c.customer_id AND o.status='completed'
LEFT JOIN order_items oi ON oi.order_id=o.order_id
GROUP BY c.customer_id,c.full_name
ORDER BY lifetime_value DESC;

-- =====================================================
-- ADVANCED ANALYTICS 4: REPEAT CUSTOMERS
-- =====================================================

SELECT c.customer_id,c.full_name,
       COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o ON o.customer_id=c.customer_id
WHERE o.status='completed'
GROUP BY c.customer_id,c.full_name
HAVING COUNT(DISTINCT o.order_id)>1
ORDER BY order_count DESC;

-- =====================================================
-- ADVANCED ANALYTICS 5: RESTOCK ALERTS
-- =====================================================

SELECT p.sku,p.product_name,i.quantity_on_hand,i.reorder_level,
       GREATEST(i.reorder_level*2-i.quantity_on_hand,0)
       AS suggested_restock_quantity
FROM inventory i
JOIN products p ON p.product_id=i.product_id
WHERE i.quantity_on_hand<=i.reorder_level
ORDER BY i.quantity_on_hand;

-- =====================================================
-- ADVANCED ANALYTICS 6: CUSTOMERS WITHOUT ORDERS
-- =====================================================

SELECT c.customer_id,c.full_name,c.email
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id=c.customer_id
);

-- =====================================================
-- ADVANCED ANALYTICS 7: RUNNING REVENUE
-- =====================================================

WITH daily_sales AS (
    SELECT DATE(o.order_date) AS sales_date,
           SUM(oi.quantity*oi.unit_price*
               (1-oi.discount_pct/100)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id=o.order_id
    WHERE o.status='completed'
    GROUP BY DATE(o.order_date)
)
SELECT sales_date,ROUND(revenue,2) AS daily_revenue,
       ROUND(SUM(revenue) OVER(
           ORDER BY sales_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ),2) AS cumulative_revenue
FROM daily_sales
ORDER BY sales_date;

-- =====================================================
-- ADVANCED ANALYTICS 8: PAYMENT RECONCILIATION
-- =====================================================

WITH order_totals AS (
    SELECT o.order_id,
           ROUND(SUM(oi.quantity*oi.unit_price*
               (1-oi.discount_pct/100)),2) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id=o.order_id
    WHERE o.status='completed'
    GROUP BY o.order_id
),
payment_totals AS (
    SELECT order_id,ROUND(SUM(amount),2) AS successful_amount
    FROM payments
    WHERE payment_status='successful'
    GROUP BY order_id
)
SELECT ot.order_id,ot.order_total,
       COALESCE(pt.successful_amount,0) AS successful_amount,
       ROUND(ot.order_total-COALESCE(pt.successful_amount,0),2)
       AS outstanding_amount
FROM order_totals ot
LEFT JOIN payment_totals pt ON pt.order_id=ot.order_id
WHERE ABS(ot.order_total-COALESCE(pt.successful_amount,0))>0.01;

-- =====================================================
-- INDEX FOR ANALYTICS
-- =====================================================

CREATE INDEX idx_orders_status_date
ON orders(status,order_date);

-- =====================================================
-- FINAL VERIFICATION
-- =====================================================

SHOW TABLES;

SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_order_items FROM order_items;

SELECT * FROM vw_completed_order_details;
SELECT * FROM vw_inventory_alerts;

CALL sp_monthly_sales('2026-01-01','2026-07-01');

SHOW TRIGGERS;


