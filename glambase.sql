DROP DATABASE IF EXISTS glambase;
CREATE DATABASE glambase;
USE glambase;

CREATE TABLE brands (
    brand_id    INT AUTO_INCREMENT PRIMARY KEY,
    brand_name  VARCHAR(100) NOT NULL,
    country     VARCHAR(60),
    website     VARCHAR(200)
);

CREATE TABLE categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_id     INT,
    description   VARCHAR(255),
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

CREATE TABLE shades (
    shade_id   INT AUTO_INCREMENT PRIMARY KEY,
    shade_name VARCHAR(80) NOT NULL,
    hex_code   VARCHAR(7),
    finish     VARCHAR(20) DEFAULT 'natural'
);

CREATE TABLE products (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    brand_id     INT NOT NULL,
    category_id  INT NOT NULL,
    description  TEXT,
    base_price   DECIMAL(10, 2) NOT NULL,
    is_active    INT DEFAULT 1,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (brand_id)    REFERENCES brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE product_images (
    image_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url  VARCHAR(300) NOT NULL,
    is_primary INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE product_shades (
    ps_id       INT AUTO_INCREMENT PRIMARY KEY,
    product_id  INT NOT NULL,
    shade_id    INT NOT NULL,
    sku         VARCHAR(60) NOT NULL UNIQUE,
    price_diff  DECIMAL(8, 2) DEFAULT 0.00,
    stock_qty   INT DEFAULT 0,
    min_stock   INT DEFAULT 10,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (shade_id)   REFERENCES shades(shade_id)
);

CREATE TABLE customers (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(60) NOT NULL,
    last_name     VARCHAR(60) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender        VARCHAR(30),
    glam_points   INT DEFAULT 0,
    tier          VARCHAR(20) DEFAULT 'bronze',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer_addresses (
    address_id  INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    label       VARCHAR(30) DEFAULT 'Home',
    street      VARCHAR(200) NOT NULL,
    city        VARCHAR(80) NOT NULL,
    province    VARCHAR(80),
    postal_code VARCHAR(20),
    country     VARCHAR(60) DEFAULT 'Pakistan',
    is_default  INT DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE glam_points_log (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    change_amt  INT NOT NULL,
    reason      VARCHAR(150),
    order_id    INT,
    logged_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    address_id      INT,
    order_status    VARCHAR(30) DEFAULT 'pending',
    subtotal        DECIMAL(12, 2) DEFAULT 0.00,
    discount_amt    DECIMAL(10, 2) DEFAULT 0.00,
    tax_amt         DECIMAL(10, 2) DEFAULT 0.00,
    shipping_amt    DECIMAL(10, 2) DEFAULT 0.00,
    total_amt       DECIMAL(12, 2) DEFAULT 0.00,
    points_redeemed INT DEFAULT 0,
    notes           TEXT,
    ordered_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (address_id)  REFERENCES customer_addresses(address_id)
);

CREATE TABLE order_items (
    item_id    INT AUTO_INCREMENT PRIMARY KEY,
    order_id   INT NOT NULL,
    ps_id      INT NOT NULL,
    quantity   INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(12, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (ps_id)    REFERENCES product_shades(ps_id)
);

CREATE TABLE payments (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL UNIQUE,
    method          VARCHAR(50) NOT NULL,
    status          VARCHAR(20) DEFAULT 'pending',
    transaction_ref VARCHAR(120),
    amount_paid     DECIMAL(12, 2) NOT NULL,
    paid_at         DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE inventory_log (
    log_id     INT AUTO_INCREMENT PRIMARY KEY,
    ps_id      INT NOT NULL,
    change_qty INT NOT NULL,
    reason     VARCHAR(30) DEFAULT 'adjustment',
    order_id   INT,
    staff_id   INT,
    qty_after  INT NOT NULL,
    logged_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ps_id) REFERENCES product_shades(ps_id)
);

CREATE TABLE staff (
    staff_id      INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(60) NOT NULL,
    last_name     VARCHAR(60) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    role          VARCHAR(30) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active     INT DEFAULT 1,
    hired_at      DATE
);

ALTER TABLE inventory_log
ADD FOREIGN KEY (staff_id) REFERENCES staff(staff_id);

CREATE TABLE shifts (
    shift_id   INT AUTO_INCREMENT PRIMARY KEY,
    staff_id   INT NOT NULL,
    shift_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time   TIME NOT NULL,
    location   VARCHAR(30) DEFAULT 'store',
    notes      TEXT,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE advisor_bookings (
    booking_id   INT AUTO_INCREMENT PRIMARY KEY,
    customer_id  INT NOT NULL,
    advisor_id   INT NOT NULL,
    session_type VARCHAR(40) DEFAULT 'everyday_glam',
    booked_date  DATE NOT NULL,
    booked_time  TIME NOT NULL,
    duration_min INT DEFAULT 45,
    status       VARCHAR(20) DEFAULT 'pending',
    notes        TEXT,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (advisor_id)  REFERENCES staff(staff_id)
);

CREATE TABLE reviews (
    review_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_id  INT NOT NULL,
    customer_id INT NOT NULL,
    rating      INT NOT NULL,
    title       VARCHAR(150),
    body        TEXT,
    is_verified INT DEFAULT 0,
    is_approved INT DEFAULT 0,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id)  REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE promo_codes (
    promo_id      INT AUTO_INCREMENT PRIMARY KEY,
    code          VARCHAR(30) NOT NULL UNIQUE,
    discount_type VARCHAR(20) DEFAULT 'percentage',
    discount_val  DECIMAL(8, 2) NOT NULL,
    min_order_amt DECIMAL(10, 2) DEFAULT 0.00,
    max_uses      INT DEFAULT 1,
    used_count    INT DEFAULT 0,
    valid_from    DATETIME,
    valid_until   DATETIME,
    is_active     INT DEFAULT 1
);

CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_date       ON orders(ordered_at);
CREATE INDEX idx_orders_status     ON orders(order_status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_products_brand    ON products(brand_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_inventory_ps      ON inventory_log(ps_id);
CREATE INDEX idx_reviews_product   ON reviews(product_id);
CREATE INDEX idx_customers_email   ON customers(email);
CREATE INDEX idx_ps_stock          ON product_shades(stock_qty);

CREATE VIEW top_selling_products AS
SELECT
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name,
    SUM(oi.quantity)                 AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    AVG(r.rating)                    AS avg_rating,
    COUNT(r.review_id)               AS total_reviews
FROM products       p
JOIN brands         b  ON b.brand_id    = p.brand_id
JOIN categories     c  ON c.category_id = p.category_id
JOIN product_shades ps ON ps.product_id = p.product_id
JOIN order_items    oi ON oi.ps_id      = ps.ps_id
JOIN orders         o  ON o.order_id    = oi.order_id
LEFT JOIN reviews   r  ON r.product_id  = p.product_id AND r.is_approved = 1
WHERE o.order_status NOT IN ('cancelled', 'refunded')
GROUP BY p.product_id, p.product_name, b.brand_name, c.category_name
ORDER BY total_units_sold DESC;

CREATE VIEW low_stock_alerts AS
SELECT
    ps.sku,
    p.product_name,
    s.shade_name,
    s.hex_code,
    ps.stock_qty AS current_stock,
    ps.min_stock AS minimum_allowed
FROM product_shades ps
JOIN products p ON p.product_id = ps.product_id
JOIN shades   s ON s.shade_id   = ps.shade_id
WHERE ps.stock_qty <= ps.min_stock
ORDER BY ps.stock_qty ASC;

CREATE VIEW order_details_full AS
SELECT
    o.order_id,
    o.ordered_at,
    o.order_status,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    p.product_name,
    sh.shade_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price)           AS line_total,
    o.total_amt,
    pay.method AS payment_method,
    pay.status AS payment_status
FROM orders         o
JOIN customers      c   ON c.customer_id = o.customer_id
JOIN order_items    oi  ON oi.order_id   = o.order_id
JOIN product_shades ps  ON ps.ps_id      = oi.ps_id
JOIN products       p   ON p.product_id  = ps.product_id
JOIN shades         sh  ON sh.shade_id   = ps.shade_id
LEFT JOIN payments  pay ON pay.order_id  = o.order_id;

CREATE VIEW customer_loyalty_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.glam_points,
    c.tier,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amt)  AS lifetime_spend
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
    AND o.order_status NOT IN ('cancelled', 'refunded')
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.glam_points, c.tier;

CREATE VIEW monthly_sales_summary AS
SELECT
    YEAR(o.ordered_at)                AS year,
    MONTH(o.ordered_at)               AS month,
    COUNT(o.order_id)                 AS total_orders,
    SUM(o.total_amt)                  AS gross_revenue,
    SUM(o.discount_amt)               AS total_discounts,
    SUM(o.total_amt - o.discount_amt) AS net_revenue
FROM orders o
WHERE o.order_status NOT IN ('cancelled', 'refunded')
GROUP BY YEAR(o.ordered_at), MONTH(o.ordered_at)
ORDER BY year DESC, month DESC;

DELIMITER $$

CREATE PROCEDURE place_order(
    IN  p_customer_id INT,
    IN  p_address_id  INT,
    IN  p_ps_id_1     INT,
    IN  p_qty_1       INT,
    IN  p_ps_id_2     INT,
    IN  p_qty_2       INT,
    IN  p_ps_id_3     INT,
    IN  p_qty_3       INT,
    IN  p_promo_code  VARCHAR(30),
    IN  p_pay_method  VARCHAR(50),
    OUT p_order_id    INT,
    OUT p_message     VARCHAR(200)
)
place_order_label: BEGIN

    DECLARE v_stock    INT DEFAULT 0;
    DECLARE v_price    DECIMAL(10,2) DEFAULT 0;
    DECLARE v_subtotal DECIMAL(12,2) DEFAULT 0;
    DECLARE v_discount DECIMAL(10,2) DEFAULT 0;
    DECLARE v_tax      DECIMAL(10,2) DEFAULT 0;
    DECLARE v_shipping DECIMAL(10,2) DEFAULT 150;
    DECLARE v_total    DECIMAL(12,2) DEFAULT 0;
    DECLARE v_new_id   INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_order_id = 0;
        SET p_message  = 'Something went wrong. Order was not placed.';
    END;

    START TRANSACTION;

    IF p_ps_id_1 IS NOT NULL THEN
        SELECT stock_qty INTO v_stock FROM product_shades WHERE ps_id = p_ps_id_1;
        IF v_stock < p_qty_1 THEN
            SET p_message = 'Not enough stock for item 1.';
            ROLLBACK;
            LEAVE place_order_label;
        END IF;
    END IF;

    IF p_ps_id_2 IS NOT NULL THEN
        SELECT stock_qty INTO v_stock FROM product_shades WHERE ps_id = p_ps_id_2;
        IF v_stock < p_qty_2 THEN
            SET p_message = 'Not enough stock for item 2.';
            ROLLBACK;
            LEAVE place_order_label;
        END IF;
    END IF;

    IF p_ps_id_3 IS NOT NULL THEN
        SELECT stock_qty INTO v_stock FROM product_shades WHERE ps_id = p_ps_id_3;
        IF v_stock < p_qty_3 THEN
            SET p_message = 'Not enough stock for item 3.';
            ROLLBACK;
            LEAVE place_order_label;
        END IF;
    END IF;

    IF p_ps_id_1 IS NOT NULL THEN
        SELECT (p.base_price + ps.price_diff) INTO v_price
        FROM product_shades ps JOIN products p ON p.product_id = ps.product_id
        WHERE ps.ps_id = p_ps_id_1;
        SET v_subtotal = v_subtotal + (v_price * p_qty_1);
    END IF;

    IF p_ps_id_2 IS NOT NULL THEN
        SELECT (p.base_price + ps.price_diff) INTO v_price
        FROM product_shades ps JOIN products p ON p.product_id = ps.product_id
        WHERE ps.ps_id = p_ps_id_2;
        SET v_subtotal = v_subtotal + (v_price * p_qty_2);
    END IF;

    IF p_ps_id_3 IS NOT NULL THEN
        SELECT (p.base_price + ps.price_diff) INTO v_price
        FROM product_shades ps JOIN products p ON p.product_id = ps.product_id
        WHERE ps.ps_id = p_ps_id_3;
        SET v_subtotal = v_subtotal + (v_price * p_qty_3);
    END IF;

    IF p_promo_code IS NOT NULL AND p_promo_code != '' THEN
        SELECT discount_val INTO v_discount
        FROM promo_codes
        WHERE code = p_promo_code
          AND is_active = 1
          AND used_count < max_uses
          AND min_order_amt <= v_subtotal
          AND (valid_until IS NULL OR valid_until >= NOW());

        IF v_discount > 0 THEN
            UPDATE promo_codes SET used_count = used_count + 1 WHERE code = p_promo_code;
        END IF;
    END IF;

    SET v_tax = (v_subtotal - v_discount) * 0.17;
    IF (v_subtotal - v_discount) >= 5000 THEN SET v_shipping = 0; END IF;
    SET v_total = v_subtotal - v_discount + v_tax + v_shipping;

    INSERT INTO orders (customer_id, address_id, subtotal, discount_amt, tax_amt, shipping_amt, total_amt)
    VALUES (p_customer_id, p_address_id, v_subtotal, v_discount, v_tax, v_shipping, v_total);

    SET v_new_id = LAST_INSERT_ID();

    IF p_ps_id_1 IS NOT NULL THEN
        SELECT (p.base_price + ps.price_diff) INTO v_price
        FROM product_shades ps JOIN products p ON p.product_id = ps.product_id
        WHERE ps.ps_id = p_ps_id_1;
        INSERT INTO order_items (order_id, ps_id, quantity, unit_price, line_total)
        VALUES (v_new_id, p_ps_id_1, p_qty_1, v_price, p_qty_1 * v_price);
        UPDATE product_shades SET stock_qty = stock_qty - p_qty_1 WHERE ps_id = p_ps_id_1;
        INSERT INTO inventory_log (ps_id, change_qty, reason, order_id, qty_after)
        SELECT p_ps_id_1, -p_qty_1, 'sale', v_new_id, stock_qty FROM product_shades WHERE ps_id = p_ps_id_1;
    END IF;

    IF p_ps_id_2 IS NOT NULL THEN
        SELECT (p.base_price + ps.price_diff) INTO v_price
        FROM product_shades ps JOIN products p ON p.product_id = ps.product_id
        WHERE ps.ps_id = p_ps_id_2;
        INSERT INTO order_items (order_id, ps_id, quantity, unit_price, line_total)
        VALUES (v_new_id, p_ps_id_2, p_qty_2, v_price, p_qty_2 * v_price);
        UPDATE product_shades SET stock_qty = stock_qty - p_qty_2 WHERE ps_id = p_ps_id_2;
        INSERT INTO inventory_log (ps_id, change_qty, reason, order_id, qty_after)
        SELECT p_ps_id_2, -p_qty_2, 'sale', v_new_id, stock_qty FROM product_shades WHERE ps_id = p_ps_id_2;
    END IF;

    IF p_ps_id_3 IS NOT NULL THEN
        SELECT (p.base_price + ps.price_diff) INTO v_price
        FROM product_shades ps JOIN products p ON p.product_id = ps.product_id
        WHERE ps.ps_id = p_ps_id_3;
        INSERT INTO order_items (order_id, ps_id, quantity, unit_price, line_total)
        VALUES (v_new_id, p_ps_id_3, p_qty_3, v_price, p_qty_3 * v_price);
        UPDATE product_shades SET stock_qty = stock_qty - p_qty_3 WHERE ps_id = p_ps_id_3;
        INSERT INTO inventory_log (ps_id, change_qty, reason, order_id, qty_after)
        SELECT p_ps_id_3, -p_qty_3, 'sale', v_new_id, stock_qty FROM product_shades WHERE ps_id = p_ps_id_3;
    END IF;

    INSERT INTO payments (order_id, method, amount_paid) VALUES (v_new_id, p_pay_method, v_total);

    COMMIT;
    SET p_order_id = v_new_id;
    SET p_message  = 'Order placed successfully!';

END place_order_label $$

CREATE PROCEDURE restock_product_shade(
    IN p_ps_id    INT,
    IN p_quantity INT,
    IN p_staff_id INT
)
BEGIN
    DECLARE v_new_qty INT;
    START TRANSACTION;
        UPDATE product_shades SET stock_qty = stock_qty + p_quantity WHERE ps_id = p_ps_id;
        SELECT stock_qty INTO v_new_qty FROM product_shades WHERE ps_id = p_ps_id;
        INSERT INTO inventory_log (ps_id, change_qty, reason, staff_id, qty_after)
        VALUES (p_ps_id, p_quantity, 'restock', p_staff_id, v_new_qty);
    COMMIT;
END $$

CREATE PROCEDURE get_customer_order_history(IN p_customer_id INT)
BEGIN
    SELECT o.order_id, o.ordered_at, o.order_status, o.total_amt,
           pay.method AS payment_method, pay.status AS payment_status
    FROM orders o
    LEFT JOIN payments pay ON pay.order_id = o.order_id
    WHERE o.customer_id = p_customer_id
    ORDER BY o.ordered_at DESC;
END $$

CREATE PROCEDURE generate_sales_report(IN p_from DATE, IN p_to DATE)
BEGIN
    SELECT
        DATE(o.ordered_at)  AS sale_date,
        COUNT(o.order_id)   AS number_of_orders,
        SUM(o.total_amt)    AS total_revenue,
        SUM(o.discount_amt) AS total_discounts,
        SUM(oi.quantity)    AS total_units_sold
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE DATE(o.ordered_at) BETWEEN p_from AND p_to
      AND o.order_status NOT IN ('cancelled', 'refunded')
    GROUP BY DATE(o.ordered_at)
    ORDER BY sale_date;
END $$

CREATE PROCEDURE update_customer_tier(IN p_customer_id INT)
BEGIN
    DECLARE v_total_spend DECIMAL(12,2) DEFAULT 0;
    SELECT SUM(total_amt) INTO v_total_spend
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status NOT IN ('cancelled', 'refunded');
    IF v_total_spend IS NULL THEN SET v_total_spend = 0; END IF;
    UPDATE customers
    SET tier = CASE
        WHEN v_total_spend >= 100000 THEN 'platinum'
        WHEN v_total_spend >= 50000  THEN 'gold'
        WHEN v_total_spend >= 20000  THEN 'silver'
        ELSE 'bronze'
    END
    WHERE customer_id = p_customer_id;
END $$

CREATE TRIGGER trg_award_glam_points
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    DECLARE v_points  INT DEFAULT 0;
    DECLARE v_amount  DECIMAL(12,2);
    DECLARE v_cust_id INT;
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        SELECT total_amt, customer_id INTO v_amount, v_cust_id
        FROM orders WHERE order_id = NEW.order_id;
        SET v_points = FLOOR(v_amount / 100);
        UPDATE customers SET glam_points = glam_points + v_points WHERE customer_id = v_cust_id;
        INSERT INTO glam_points_log (customer_id, change_amt, reason, order_id)
        VALUES (v_cust_id, v_points, 'earned from purchase', NEW.order_id);
        CALL update_customer_tier(v_cust_id);
    END IF;
END $$

CREATE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE ON product_shades
FOR EACH ROW
BEGIN
    IF NEW.stock_qty < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: stock cannot go below zero.';
    END IF;
END $$

CREATE TRIGGER trg_confirm_order_on_payment
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        UPDATE orders SET order_status = 'confirmed'
        WHERE order_id = NEW.order_id AND order_status = 'pending';
    END IF;
END $$

CREATE TRIGGER trg_log_inventory_on_item
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM inventory_log WHERE ps_id = NEW.ps_id AND order_id = NEW.order_id
    ) THEN
        INSERT INTO inventory_log (ps_id, change_qty, reason, order_id, qty_after)
        SELECT NEW.ps_id, -NEW.quantity, 'sale', NEW.order_id, stock_qty
        FROM product_shades WHERE ps_id = NEW.ps_id;
    END IF;
END $$

CREATE TRIGGER trg_verify_review
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM orders o
        JOIN order_items    oi ON oi.order_id = o.order_id
        JOIN product_shades ps ON ps.ps_id    = oi.ps_id
        WHERE o.customer_id = NEW.customer_id
          AND ps.product_id = NEW.product_id
          AND o.order_status = 'delivered'
    ) THEN
        SET NEW.is_verified = 1;
    END IF;
END $$

DELIMITER ;

INSERT INTO brands (brand_name, country) VALUES
    ('Huda Beauty',       'UAE'),
    ('Charlotte Tilbury', 'UK'),
    ('L.A. Girl',         'USA'),
    ('Medora',            'Pakistan'),
    ('Rivaj UK',          'Pakistan'),
    ('NYX Professional',  'USA');

INSERT INTO categories (category_name, description) VALUES
    ('Lips',     'Lipsticks, glosses, liners'),
    ('Eyes',     'Mascaras, eyeshadows, liners'),
    ('Face',     'Foundations, blushes, highlighters'),
    ('Skincare', 'Serums, moisturizers, cleansers'),
    ('Tools',    'Brushes, sponges, accessories');

INSERT INTO categories (category_name, parent_id, description) VALUES
    ('Lipstick',   1, 'Bullet lipsticks'),
    ('Lip Gloss',  1, 'Glossy lip products'),
    ('Eyeshadow',  2, 'Palettes and singles'),
    ('Foundation', 3, 'Liquid and powder foundations'),
    ('Blush',      3, 'Powder and cream blushes');

INSERT INTO shades (shade_name, hex_code, finish) VALUES
    ('Classic Red',   '#C0392B', 'matte'),
    ('Nude Beige',    '#D4A574', 'satin'),
    ('Rose Gold',     '#B76E79', 'metallic'),
    ('Berry Wine',    '#722F37', 'matte'),
    ('Coral Crush',   '#FF6B6B', 'glossy'),
    ('Desert Sand',   '#EDC9AF', 'natural'),
    ('Midnight Plum', '#4A0E4E', 'matte'),
    ('Cotton Candy',  '#FFB7C5', 'shimmer'),
    ('Ivory',         '#FFFFF0', 'natural'),
    ('Warm Peach',    '#FFAD88', 'satin');

INSERT INTO products (product_name, brand_id, category_id, description, base_price) VALUES
    ('Power Bullet Lipstick', 1, 6,  'High-pigment matte formula, lasts 12 hours',          2500.00),
    ('Pillow Lips Gloss',     1, 7,  'Plumping lip gloss with hyaluronic acid',              1800.00),
    ('Pro HD Foundation',     3, 9,  'Full-coverage liquid foundation',                      1200.00),
    ('Flawless Finish Base',  2, 9,  'Medium coverage with satin finish',                    4500.00),
    ('Glow Blush Duo',        6, 10, 'Pressed blush and highlighter in one palette',         1600.00),
    ('Mega Lash Mascara',     4, 2,  'Volumising mascara, smudge-proof',                      900.00),
    ('Intense Kohl Liner',    5, 2,  'Waterproof kohl pencil',                                550.00),
    ('Velvet Matte Lipstick', 5, 6,  'Long-lasting matte lipstick, made in Pakistan',         650.00);

INSERT INTO product_shades (product_id, shade_id, sku, price_diff, stock_qty) VALUES
    (1, 1, 'GB-PBL-RED', 0,   45),
    (1, 2, 'GB-PBL-NUD', 0,   60),
    (1, 4, 'GB-PBL-BRY', 0,   30),
    (1, 7, 'GB-PBL-PLM', 0,   8),
    (2, 3, 'GB-PLG-RGD', 200, 50),
    (2, 5, 'GB-PLG-CRL', 0,   40),
    (3, 6, 'GB-PHF-SND', 0,   100),
    (3, 9, 'GB-PHF-IVY', 0,   85),
    (4, 6, 'GB-FFB-SND', 500, 25),
    (4, 9, 'GB-FFB-IVY', 500, 15),
    (5, 3, 'GB-GBD-RGD', 0,   70),
    (5, 8, 'GB-GBD-CCY', 0,   55),
    (6, 1, 'GB-MML-BLK', 0,   200),
    (7, 1, 'GB-IKL-BLK', 0,   300),
    (8, 1, 'GB-VML-RED', 0,   9),
    (8, 2, 'GB-VML-NUD', 0,   75);

INSERT INTO staff (first_name, last_name, email, phone, role, password_hash, hired_at) VALUES
    ('Ayesha', 'Khan',  'ayesha.admin@glambase.pk',  '0300-1111111', 'admin',          SHA2('Admin@123', 256), '2023-01-01'),
    ('Zara',   'Ahmed', 'zara.advisor@glambase.pk',  '0301-2222222', 'beauty_advisor', SHA2('Adv@2023',  256), '2023-03-15'),
    ('Hamza',  'Ali',   'hamza.cashier@glambase.pk', '0302-3333333', 'cashier',        SHA2('Cash@456',  256), '2023-06-01'),
    ('Fatima', 'Malik', 'fatima.mgr@glambase.pk',    '0303-4444444', 'manager',        SHA2('Mgr@789',   256), '2023-01-10');

INSERT INTO customers (first_name, last_name, email, phone, password_hash, date_of_birth, gender) VALUES
    ('Sara',  'Qureshi',  'sara.q@email.com',  '0311-1234567', SHA2('Sara@pass',  256), '1995-05-12', 'female'),
    ('Laiba', 'Hassan',   'laiba.h@email.com', '0321-9876543', SHA2('Laiba@pass', 256), '1998-08-22', 'female'),
    ('Nadia', 'Siddiqui', 'nadia.s@email.com', '0331-5551234', SHA2('Nadia@pass', 256), '1990-11-30', 'female');

INSERT INTO customer_addresses (customer_id, label, street, city, province, postal_code, is_default) VALUES
    (1, 'Home',   'B-12 Block 5, Clifton',  'Karachi', 'Sindh',  '75600', 1),
    (2, 'Home',   'House 7, DHA Phase 4',   'Karachi', 'Sindh',  '75500', 1),
    (3, 'Office', 'Room 4, Liberty Market', 'Lahore',  'Punjab', '54000', 1);

INSERT INTO promo_codes (code, discount_type, discount_val, min_order_amt, max_uses, valid_until) VALUES
    ('GLAM20', 'percentage', 20.00, 1000.00, 100, '2026-12-31');

SELECT * FROM products;
