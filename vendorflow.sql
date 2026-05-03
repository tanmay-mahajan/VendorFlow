-- ============================================================
-- VendorFlow – Smart Vendor Queue & Order Management System
-- PostgreSQL Database Schema + Sample Data
-- ============================================================

-- Drop tables in reverse dependency order (if they exist)
DROP TABLE IF EXISTS feedback      CASCADE;
DROP TABLE IF EXISTS payments      CASCADE;
DROP TABLE IF EXISTS order_items   CASCADE;
DROP TABLE IF EXISTS orders        CASCADE;
DROP TABLE IF EXISTS menu_items    CASCADE;
DROP TABLE IF EXISTS users         CASCADE;

-- ============================================================
-- TABLE: users
-- Stores customers, vendors, and admins in a single table.
-- role: 'customer' | 'vendor' | 'admin'
-- ============================================================
CREATE TABLE users (
    id           SERIAL       PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    email        VARCHAR(150) NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,
    phone        VARCHAR(15),
    role         VARCHAR(20)  NOT NULL DEFAULT 'customer'
                     CHECK (role IN ('customer','vendor','admin')),
    shop_name    VARCHAR(150),          -- only for vendors
    shop_address TEXT,                  -- only for vendors
    created_at   TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: menu_items
-- Each vendor's menu items.
-- ============================================================
CREATE TABLE menu_items (
    id           SERIAL        PRIMARY KEY,
    vendor_id    INT           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name         VARCHAR(150)  NOT NULL,
    description  TEXT,
    price        NUMERIC(8,2)  NOT NULL CHECK (price >= 0),
    category     VARCHAR(80)   DEFAULT 'General',
    is_available BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: orders
-- One record per customer order; holds status + token.
-- ============================================================
CREATE TABLE orders (
    id             SERIAL       PRIMARY KEY,
    customer_id    INT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vendor_id      INT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_number   INT          NOT NULL,
    total_amount   NUMERIC(10,2) NOT NULL DEFAULT 0,
    status         VARCHAR(20)  NOT NULL DEFAULT 'Pending'
                       CHECK (status IN ('Pending','Preparing','Ready','Completed','Cancelled')),
    special_notes  TEXT,
    created_at     TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Token is unique per vendor per day
CREATE UNIQUE INDEX idx_orders_token_vendor_date
    ON orders (vendor_id, token_number, DATE(created_at));

-- ============================================================
-- TABLE: order_items
-- Line items for each order.
-- ============================================================
CREATE TABLE order_items (
    id           SERIAL        PRIMARY KEY,
    order_id     INT           NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id INT           NOT NULL REFERENCES menu_items(id) ON DELETE RESTRICT,
    quantity     INT           NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price   NUMERIC(8,2)  NOT NULL,
    subtotal     NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

-- ============================================================
-- TABLE: payments
-- One payment record per order.
-- ============================================================
CREATE TABLE payments (
    id             SERIAL       PRIMARY KEY,
    order_id       INT          NOT NULL REFERENCES orders(id) ON DELETE CASCADE UNIQUE,
    amount         NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(50)  DEFAULT 'Cash',
    payment_status VARCHAR(20)  NOT NULL DEFAULT 'Pending'
                       CHECK (payment_status IN ('Pending','Paid','Refunded')),
    paid_at        TIMESTAMP
);

-- ============================================================
-- TABLE: feedback
-- Customer feedback / rating per order.
-- ============================================================
CREATE TABLE feedback (
    id          SERIAL      PRIMARY KEY,
    customer_id INT         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vendor_id   INT         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id    INT         REFERENCES orders(id) ON DELETE SET NULL,
    rating      INT         NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comments    TEXT,
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW()
);

-- ============================================================
-- FUNCTION: auto-update orders.updated_at on row change
-- ============================================================
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_orders_updated
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- Admin user (password: admin123)
INSERT INTO users (name, email, password, phone, role)
VALUES ('Admin', 'admin@vendorflow.com', 'admin123', '9000000000', 'admin');

-- Vendor 1 (password: vendor123)
INSERT INTO users (name, email, password, phone, role, shop_name, shop_address)
VALUES ('Ravi Kumar', 'ravi@vendorflow.com', 'vendor123', '9111111111',
        'vendor', 'Ravi Juice Center', 'Block A, College Campus');

-- Vendor 2
INSERT INTO users (name, email, password, phone, role, shop_name, shop_address)
VALUES ('Priya Sharma', 'priya@vendorflow.com', 'vendor123', '9222222222',
        'vendor', 'Priya Snack Corner', 'Block B, College Campus');

-- Customer 1 (password: cust123)
INSERT INTO users (name, email, password, phone, role)
VALUES ('Amit Patel', 'amit@vendorflow.com', 'cust123', '9333333333', 'customer');

-- Customer 2
INSERT INTO users (name, email, password, phone, role)
VALUES ('Sneha Roy', 'sneha@vendorflow.com', 'cust123', '9444444444', 'customer');

-- Menu items for Vendor 1 (id=2)
INSERT INTO menu_items (vendor_id, name, description, price, category) VALUES
(2, 'Fresh Lime Juice',  'Chilled lime juice with salt or sugar',  25.00, 'Juice'),
(2, 'Watermelon Juice',  'Fresh watermelon blend',                 30.00, 'Juice'),
(2, 'Mango Milkshake',   'Thick mango milkshake',                  45.00, 'Shake'),
(2, 'Veg Sandwich',      'Grilled sandwich with veggies',          40.00, 'Snack'),
(2, 'Masala Chai',       'Ginger-cardamom tea',                    15.00, 'Beverage');

-- Menu items for Vendor 2 (id=3)
INSERT INTO menu_items (vendor_id, name, description, price, category) VALUES
(3, 'Samosa',       '2 pcs crispy samosa with chutney',   20.00, 'Snack'),
(3, 'Pav Bhaji',    'Mumbai-style pav bhaji',             60.00, 'Meal'),
(3, 'Vada Pav',     'Mumbai vada pav',                    25.00, 'Snack'),
(3, 'Bhel Puri',    'Tangy bhel puri',                    30.00, 'Snack'),
(3, 'Cold Coffee',  'Blended cold coffee',                40.00, 'Beverage');

-- Sample orders for vendor 2 (customer amit, id=4)
INSERT INTO orders (customer_id, vendor_id, token_number, total_amount, status)
VALUES (4, 2, 1, 70.00,  'Completed'),
       (4, 2, 2, 45.00,  'Completed'),
       (5, 2, 3, 110.00, 'Preparing'),
       (4, 2, 4, 55.00,  'Pending');

-- Order items
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(1, 1, 2, 25.00),  -- 2x lime juice
(1, 4, 1, 40.00),  -- veg sandwich (but note: these are vendor2 orders, adjust)
(2, 3, 1, 45.00),  -- mango shake
(3, 3, 2, 45.00),  -- 2x mango shake
(3, 5, 1, 15.00),  -- chai
(4, 1, 1, 25.00),  -- lime juice
(4, 5, 2, 15.00);  -- 2x chai

-- Payments
INSERT INTO payments (order_id, amount, payment_method, payment_status, paid_at) VALUES
(1, 70.00,  'Cash', 'Paid', NOW() - INTERVAL '2 days'),
(2, 45.00,  'Cash', 'Paid', NOW() - INTERVAL '1 day'),
(3, 110.00, 'Cash', 'Pending', NULL),
(4, 55.00,  'Cash', 'Pending', NULL);

-- Feedback
INSERT INTO feedback (customer_id, vendor_id, order_id, rating, comments) VALUES
(4, 2, 1, 5, 'Excellent juice, very fresh!'),
(4, 2, 2, 4, 'Good shake but little sweet'),
(5, 2, 3, 5, 'Loved the mango milkshake!');

-- ============================================================
-- Useful VIEWS for analytics
-- ============================================================
CREATE OR REPLACE VIEW v_daily_orders AS
SELECT DATE(created_at) AS order_date,
       vendor_id,
       COUNT(*) AS total_orders,
       SUM(total_amount) AS revenue
FROM orders
GROUP BY DATE(created_at), vendor_id;

CREATE OR REPLACE VIEW v_popular_items AS
SELECT mi.name AS item_name,
       mi.vendor_id,
       SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN menu_items mi ON oi.menu_item_id = mi.id
GROUP BY mi.name, mi.vendor_id
ORDER BY total_sold DESC;
