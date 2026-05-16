# VendorFlow - Database Documentation

## Overview

VendorFlow uses PostgreSQL as its primary database management system. The database follows a normalized relational design with proper constraints, indexes, and relationships to ensure data integrity and efficient query performance.

---

## Database Configuration

### Connection Details
- **Database Name:** `vendorflow`
- **Host:** localhost
- **Port:** 5432
- **Driver:** PostgreSQL JDBC Driver 42.7.3
- **Connection String:** `jdbc:postgresql://localhost:5432/vendorflow`

### JDBC Connection
```java
Class.forName("org.postgresql.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:postgresql://localhost:5432/vendorflow",
    "postgres",
    "your_password"
);
```

---

## Schema Structure

### Tables (6)
1. **users** - User accounts (customers, vendors, admins)
2. **menu_items** - Vendor menu items
3. **orders** - Customer orders
4. **order_items** - Line items for orders
5. **payments** - Payment records
6. **feedback** - Customer feedback and ratings

### Views (2)
1. **v_daily_orders** - Daily order summary by vendor
2. **v_popular_items** - Popular items ranking

### Functions (1)
1. **update_timestamp()** - Auto-update timestamp trigger

### Triggers (1)
1. **trg_orders_updated** - Updates `updated_at` on order changes

---

## Detailed Table Specifications

### 1. users

**Purpose:** Stores all user accounts (customers, vendors, admins) in a single table with role-based differentiation.

**Schema:**
```sql
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
```

**Columns:**
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | AUTO_INCREMENT | Unique user identifier |
| name | VARCHAR(100) | NO | - | Full name |
| email | VARCHAR(150) | NO | - | Email address (unique) |
| password | VARCHAR(255) | NO | - | Password (plain text ⚠️) |
| phone | VARCHAR(15) | YES | NULL | Phone number |
| role | VARCHAR(20) | NO | 'customer' | User role |
| shop_name | VARCHAR(150) | YES | NULL | Vendor's shop name |
| shop_address | TEXT | YES | NULL | Vendor's address |
| created_at | TIMESTAMP | NO | NOW() | Account creation time |

**Indexes:**
- PRIMARY KEY: `id`
- UNIQUE: `email`
- No index on `role` (low cardinality)

**Constraints:**
- `CHECK (role IN ('customer','vendor','admin'))`
- `NOT NULL` on required fields

**Sample Data:**
```sql
INSERT INTO users (name, email, password, phone, role, shop_name, shop_address) 
VALUES 
('Ravi Kumar', 'ravi@vendorflow.com', 'vendor123', '9111111111',
 'vendor', 'Ravi Juice Center', 'Block A, College Campus'),
('Amit Patel', 'amit@vendorflow.com', 'cust123', '9333333333', 
 'customer', NULL, NULL),
('Admin', 'admin@vendorflow.com', 'admin123', '9000000000',
 'admin', NULL, NULL);
```

**Relationships:**
- Parent of: `orders` (via customer_id, vendor_id)
- Parent of: `menu_items` (via vendor_id)
- Parent of: `feedback` (via customer_id, vendor_id)

**Usage Notes:**
- Role determines user permissions in application
- Vendor-specific fields nullable for non-vendors
- Email used as login identifier
- Password stored in plaintext (security concern ⚠️)

---

### 2. menu_items

**Purpose:** Stores menu items offered by vendors.

**Schema:**
```sql
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
```

**Columns:**
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | AUTO_INCREMENT | Unique item identifier |
| vendor_id | INT | NO | - | Owner vendor (FK to users) |
| name | VARCHAR(150) | NO | - | Item name |
| description | TEXT | YES | NULL | Item description |
| price | NUMERIC(8,2) | NO | - | Price (≥0) |
| category | VARCHAR(80) | YES | 'General' | Item category |
| is_available | BOOLEAN | NO | TRUE | Availability flag |
| created_at | TIMESTAMP | NO | NOW() | Item creation time |

**Indexes:**
- PRIMARY KEY: `id`
- No index on `vendor_id` (consider adding for query performance)

**Constraints:**
- `CHECK (price >= 0)`
- `FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE`

**Sample Data:**
```sql
INSERT INTO menu_items (vendor_id, name, description, price, category) VALUES
(2, 'Fresh Lime Juice', 'Chilled lime juice with salt or sugar', 25.00, 'Juice'),
(2, 'Veg Sandwich', 'Grilled sandwich with veggies', 40.00, 'Snack'),
(3, 'Samosa', '2 pcs crispy samosa with chutney', 20.00, 'Snack');
```

**Relationships:**
- Child of: `users` (vendor_id)
- Parent of: `order_items` (via menu_item_id)

**Usage Notes:**
- Soft delete via `is_available` flag
- Price precision: 2 decimal places
- Categories allow menu organization
- Vendor can have multiple menu items
- ON DELETE CASCADE: Items removed when vendor deleted

---

### 3. orders

**Purpose:** Stores order headers with token-based tracking.

**Schema:**
```sql
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

CREATE UNIQUE INDEX idx_orders_token_vendor_date
    ON orders (vendor_id, token_number, DATE(created_at));
```

**Columns:**
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | AUTO_INCREMENT | Unique order identifier |
| customer_id | INT | NO | - | Ordering customer (FK) |
| vendor_id | INT | NO | - | Receiving vendor (FK) |
| token_number | INT | NO | - | FCFS token for the day |
| total_amount | NUMERIC(10,2) | NO | 0 | Order total |
| status | VARCHAR(20) | NO | 'Pending' | Current status |
| special_notes | TEXT | YES | NULL | Customer notes |
| created_at | TIMESTAMP | NO | NOW() | Order creation time |
| updated_at | TIMESTAMP | NO | NOW() | Last update time |

**Indexes:**
- PRIMARY KEY: `id`
- UNIQUE: `(vendor_id, token_number, DATE(created_at))`
- Consider: `(customer_id, created_at)` for customer history queries

**Constraints:**
- `CHECK (status IN ('Pending','Preparing','Ready','Completed','Cancelled'))`
- `FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE`
- `FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE`

**Sample Data:**
```sql
INSERT INTO orders (customer_id, vendor_id, token_number, total_amount, status) VALUES
(4, 2, 1, 70.00, 'Completed'),
(4, 2, 2, 45.00, 'Completed'),
(5, 2, 3, 110.00, 'Preparing'),
(4, 2, 4, 55.00, 'Pending');
```

**Relationships:**
- Child of: `users` (customer_id, vendor_id)
- Parent of: `order_items` (via order_id)
- Parent of: `payments` (via order_id)
- Parent of: `feedback` (via order_id)

**Usage Notes:**
- Token uniqueness enforced per vendor per day
- Status follows strict lifecycle
- total_amount should match sum of order_items
- updated_at auto-maintained via trigger
- ON DELETE CASCADE: Related data removed when user deleted

---

### 4. order_items

**Purpose:** Stores line items for each order (order details).

**Schema:**
```sql
CREATE TABLE order_items (
    id           SERIAL        PRIMARY KEY,
    order_id     INT           NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id INT           NOT NULL REFERENCES menu_items(id) ON DELETE RESTRICT,
    quantity     INT           NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price   NUMERIC(8,2)  NOT NULL,
    subtotal     NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);
```

**Columns:**
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | AUTO_INCREMENT | Line item identifier |
| order_id | INT | NO | - | Parent order (FK) |
| menu_item_id | INT | NO | - | Menu item ordered (FK) |
| quantity | INT | NO | 1 | Quantity ordered |
| unit_price | NUMERIC(8,2) | NO | - | Price at time of order |
| subtotal | NUMERIC(10,2) | NO | - | Calculated (quantity × unit_price) |

**Indexes:**
- PRIMARY KEY: `id`
- Consider: `(order_id)` for order detail queries
- Consider: `(menu_item_id)` for item popularity analysis

**Constraints:**
- `CHECK (quantity > 0)`
- `FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE`
- `FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE RESTRICT`

**Sample Data:**
```sql
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(1, 1, 2, 25.00),  -- 2x lime juice
(1, 4, 1, 40.00),  -- veg sandwich
(2, 3, 1, 45.00);  -- mango shake
```

**Relationships:**
- Child of: `orders` (order_id)
- Child of: `menu_items` (menu_item_id)

**Usage Notes:**
- Stores historical prices (unit_price) independent of current menu price
- Generated column `subtotal` computed automatically
- RESTRICT delete: Cannot delete menu item if referenced in orders
- ON DELETE CASCADE: Items removed when order deleted

---

### 5. payments

**Purpose:** Stores payment records for orders (single payment per order).

**Schema:**
```sql
CREATE TABLE payments (
    id             SERIAL       PRIMARY KEY,
    order_id       INT          NOT NULL REFERENCES orders(id) ON DELETE CASCADE UNIQUE,
    amount         NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(50)  DEFAULT 'Cash',
    payment_status VARCHAR(20)  NOT NULL DEFAULT 'Pending'
                       CHECK (payment_status IN ('Pending','Paid','Refunded')),
    paid_at        TIMESTAMP
);
```

**Columns:**
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | AUTO_INCREMENT | Payment identifier |
| order_id | INT | NO | - | Associated order (FK) |
| amount | NUMERIC(10,2) | NO | - | Payment amount |
| payment_method | VARCHAR(50) | YES | 'Cash' | Payment method |
| payment_status | VARCHAR(20) | NO | 'Pending' | Payment status |
| paid_at | TIMESTAMP | YES | NULL | Payment timestamp |

**Indexes:**
- PRIMARY KEY: `id`
- UNIQUE: `order_id` (one payment per order)
- Consider: `(payment_status)` for payment processing queries

**Constraints:**
- `CHECK (payment_status IN ('Pending','Paid','Refunded'))`
- `FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE`
- `UNIQUE (order_id)`

**Sample Data:**
```sql
INSERT INTO payments (order_id, amount, payment_method, payment_status, paid_at) VALUES
(1, 70.00, 'Cash', 'Paid', NOW() - INTERVAL '2 days'),
(2, 45.00, 'Cash', 'Paid', NOW() - INTERVAL '1 day'),
(3, 110.00, 'Cash', 'Pending', NULL);
```

**Relationships:**
- Child of: `orders` (order_id)

**Usage Notes:**
- One-to-one relationship with orders (enforced by UNIQUE)
- Supports multiple payment methods
- Tracks payment status lifecycle
- Paid_at indicates when payment completed
- Current implementation: Cash only, paid at pickup (future enhancement needed)

---

### 6. feedback

**Purpose:** Stores customer feedback and ratings for orders/vendors.

**Schema:**
```sql
CREATE TABLE feedback (
    id          SERIAL      PRIMARY KEY,
    customer_id INT         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vendor_id   INT         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id    INT         REFERENCES orders(id) ON DELETE SET NULL,
    rating      INT         NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comments    TEXT,
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW()
);
```

**Columns:**
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | AUTO_INCREMENT | Feedback identifier |
| customer_id | INT | NO | - | Customer providing feedback (FK) |
| vendor_id | INT | NO | - | Vendor being reviewed (FK) |
| order_id | INT | YES | NULL | Related order (FK, nullable) |
| rating | INT | NO | - | Rating: 1-5 |
| comments | TEXT | YES | NULL | Written feedback |
| created_at | TIMESTAMP | NO | NOW() | Feedback timestamp |

**Indexes:**
- PRIMARY KEY: `id`
- Consider: `(vendor_id)` for vendor review queries
- Consider: `(customer_id)` for customer history

**Constraints:**
- `CHECK (rating BETWEEN 1 AND 5)`
- `FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE`
- `FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE`
- `FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL`

**Sample Data:**
```sql
INSERT INTO feedback (customer_id, vendor_id, order_id, rating, comments) VALUES
(4, 2, 1, 5, 'Excellent juice, very fresh!'),
(4, 2, 2, 4, 'Good shake but little sweet'),
(5, 2, 3, 5, 'Loved the mango milkshake!');
```

**Relationships:**
- Child of: `users` (customer_id, vendor_id)
- Child of: `orders` (order_id)

**Usage Notes:**
- Order_id nullable: feedback can be general (not order-specific)
- Rating restricted to 1-5 scale
- ON DELETE SET NULL: Feedback preserved if order deleted
- CASCADE: Feedback removed if customer/vendor deleted

---

## Views

### 1. v_daily_orders

**Purpose:** Summary of daily orders by vendor for reporting.

**Definition:**
```sql
CREATE OR REPLACE VIEW v_daily_orders AS
SELECT 
    DATE(created_at) AS order_date,
    vendor_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS revenue
FROM orders
GROUP BY DATE(created_at), vendor_id;
```

**Columns:**
- `order_date`: Date of orders
- `vendor_id`: Vendor identifier
- `total_orders`: Number of orders on that date
- `revenue`: Total revenue for that date/vendor

**Usage:**
```sql
SELECT * FROM v_daily_orders 
WHERE vendor_id = 2 
ORDER BY order_date DESC;
```

---

### 2. v_popular_items

**Purpose:** Ranking of menu items by total quantity sold.

**Definition:**
```sql
CREATE OR REPLACE VIEW v_popular_items AS
SELECT 
    mi.name AS item_name,
    mi.vendor_id,
    SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN menu_items mi ON oi.menu_item_id = mi.id
GROUP BY mi.name, mi.vendor_id
ORDER BY total_sold DESC;
```

**Columns:**
- `item_name`: Menu item name
- `vendor_id`: Vendor identifier
- `total_sold`: Total quantity sold across all orders

**Usage:**
```sql
SELECT * FROM v_popular_items 
WHERE vendor_id = 2 
LIMIT 10;
```

---

## Functions

### update_timestamp()

**Purpose:** Updates `updated_at` timestamp for orders table.

**Definition:**
```sql
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Usage:** Called by `trg_orders_updated` trigger.

---

## Triggers

### trg_orders_updated

**Purpose:** Automatically updates `updated_at` when order row is modified.

**Definition:**
```sql
CREATE TRIGGER trg_orders_updated
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
```

**Timing:** BEFORE UPDATE
**Scope:** Each row
**Table:** orders

---

## Database Relationships Diagram

```mermaid
erDiagram
    USERS {
        int id PK
        string name
        string email UK
        string password
        string role
        string shop_name
        string shop_address
        timestamp created_at
    }
    
    MENU_ITEMS {
        int id PK
        int vendor_id FK
        string name
        text description
        decimal price
        string category
        boolean is_available
        timestamp created_at
    }
    
    ORDERS {
        int id PK
        int customer_id FK
        int vendor_id FK
        int token_number
        decimal total_amount
        string status
        text special_notes
        timestamp created_at
        timestamp updated_at
    }
    
    ORDER_ITEMS {
        int id PK
        int order_id FK
        int menu_item_id FK
        int quantity
        decimal unit_price
        decimal subtotal
    }
    
    PAYMENTS {
        int id PK
        int order_id FK UK
        decimal amount
        string payment_method
        string payment_status
        timestamp paid_at
    }
    
    FEEDBACK {
        int id PK
        int customer_id FK
        int vendor_id FK
        int order_id FK
        int rating
        text comments
        timestamp created_at
    }
    
    USERS ||--o{ ORDERS : places
    USERS ||--o{ ORDERS : receives
    USERS ||--o{ MENU_ITEMS : manages
    USERS ||--o{ FEEDBACK : provides
    USERS ||--o{ FEEDBACK : receives
    ORDERS ||--|{ ORDER_ITEMS : contains
    ORDERS ||--|| PAYMENTS : has
    ORDERS ||--|| FEEDBACK : receives
    MENU_ITEMS ||--|{ ORDER_ITEMS : included in
```

---

## Query Patterns

### 1. Get Today's Queue for Vendor
```sql
SELECT o.*, u.name AS customer_name
FROM orders o 
JOIN users u ON o.customer_id = u.id
WHERE o.vendor_id = ?
  AND o.status NOT IN ('Completed','Cancelled')
  AND DATE(o.created_at) = CURRENT_DATE
ORDER BY o.token_number ASC;
```

### 2. Get Vendor's Menu
```sql
SELECT * FROM menu_items 
WHERE vendor_id = ? 
  AND is_available = TRUE 
ORDER BY category, name;
```

### 3. Calculate Order Total
```sql
SELECT SUM(oi.quantity * oi.unit_price) AS total
FROM order_items oi
WHERE oi.order_id = ?;
```

### 4. Get Customer Order History
```sql
SELECT o.*, u.shop_name AS vendor_shop_name
FROM orders o
JOIN users u ON o.vendor_id = u.id
WHERE o.customer_id = ?
ORDER BY o.created_at DESC;
```

### 5. Get Vendor Analytics
```sql
SELECT 
    DATE(o.created_at) AS order_date,
    COUNT(*) AS total_orders,
    SUM(o.total_amount) AS total_revenue
FROM orders o
WHERE o.vendor_id = ?
  AND o.created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(o.created_at)
ORDER BY order_date DESC;
```

---

## Indexing Strategy

### Current Indexes
1. **PRIMARY KEY** on all `id` columns (automatically created)
2. **UNIQUE** on `users.email`
3. **UNIQUE** on `(vendor_id, token_number, DATE(created_at))` for orders
4. **UNIQUE** on `payments.order_id`

### Recommended Additional Indexes

```sql
-- For customer order history queries
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- For vendor order queries
CREATE INDEX idx_orders_vendor_id ON orders(vendor_id);

-- For menu item lookup by vendor
CREATE INDEX idx_menu_items_vendor_id ON menu_items(vendor_id);

-- For feedback queries
CREATE INDEX idx_feedback_vendor_id ON feedback(vendor_id);
CREATE INDEX idx_feedback_customer_id ON feedback(customer_id);

-- For date-based queries
CREATE INDEX idx_orders_created_at ON orders(DATE(created_at));
CREATE INDEX idx_feedback_created_at ON feedback(DATE(created_at));

-- Composite index for queue queries
CREATE INDEX idx_orders_queue ON orders(vendor_id, status, DATE(created_at));
```

---

## Performance Considerations

### Query Optimization
- Use `EXPLAIN ANALYZE` to review query plans
- Avoid `SELECT *` - specify needed columns
- Use JOINs instead of subqueries where possible
- Leverage indexes for WHERE clauses

### Connection Management
- Current: New connection per request (not pooled)
- Recommendation: Implement connection pooling (HikariCP)

### Transaction Management
- Use transactions for multi-statement operations
- Keep transactions short to reduce lock contention
- Handle deadlocks with retry logic

### Data Types
- Use appropriate numeric types for prices (NUMERIC for currency)
- Use TIMESTAMP with timezone awareness (consider TIMESTAMPTZ)
- VARCHAR lengths optimized for actual data

---

## Backup Strategy

### Current Status
No automated backup configured.

### Recommended Approach
1. **Daily Full Backup**
   ```bash
   pg_dump -U postgres -d vendorflow -F c -f backup_$(date +%Y%m%d).dump
   ```

2. **Hourly WAL Archiving** (for point-in-time recovery)
3. **Off-site Storage** of backups
4. **Regular Restore Testing**

---

## Security Considerations

### Current Implementation
- Database password in plaintext (DBConnection.java)
- No connection encryption
- No row-level security

### Recommended Improvements
1. **Use Environment Variables** for database credentials
2. **Enable SSL/TLS** for database connections
3. **Implement Row-Level Security** (RLS) for multi-tenant isolation
4. **Use Connection Pooling** with credential management
5. **Audit Logging** of database access
6. **Regular Security Updates** for PostgreSQL
7. **Least Privilege** principle for database user

---

## Migration Considerations

### Schema Version 1.0 → 2.0
Potential changes:
1. Add `updated_at` to all tables (via trigger)
2. Add soft delete flags (`is_deleted`)
3. Normalize categories into separate table
4. Add user avatar/image support
5. Implement proper password hashing column
6. Add indexes for foreign keys
7. Partition orders by date for large datasets

---

## Monitoring

### Key Metrics to Track
1. Query execution time
2. Connection pool utilization
3. Table sizes and growth rate
4. Index usage statistics
5. Lock contention
6. Replication lag (if applicable)

### Useful Queries
```sql
-- Table sizes
SELECT 
    table_name,
    pg_size_pretty(pg_total_relation_size(table_name)) AS size
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY pg_total_relation_size(table_name) DESC;

-- Index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Slow queries
SELECT 
    query,
    calls,
    total_exec_time,
    mean_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

---

## Conclusion

The VendorFlow database schema demonstrates solid relational design principles:

**Strengths:**
- Proper normalization (3NF)
- Appropriate use of constraints
- Clear foreign key relationships
- Support for business requirements
- Well-designed token generation system
- Comprehensive data integrity

**Areas for Enhancement:**
- Add more indexes for performance
- Implement connection pooling
- Enhance security (credentials, encryption)
- Add audit trails
- Consider partitioning for scale

The schema provides a robust foundation that can scale to support hundreds of vendors and thousands of daily orders with proper indexing and infrastructure.

---
*Last Updated: 2026-05-07*
*PostgreSQL Version: 14+ Compatible*
