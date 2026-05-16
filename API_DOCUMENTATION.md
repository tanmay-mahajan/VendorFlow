# VendorFlow - API Documentation

## Overview

VendorFlow exposes a REST-like API through Java Servlets for all client-server interactions. All endpoints use standard HTTP methods and return responses via server-side redirects or JSP rendering.

---

## Authentication

### Session-Based Authentication
All protected endpoints require an active session with appropriate role.

**Session Attributes:**
- `userId` (Integer): User's unique identifier
- `userName` (String): User's display name
- `userRole` (String): Role (customer/vendor/admin)
- `userEmail` (String): User's email address
- `vendorId` (Integer): Vendor ID (vendors only)

---

## Authentication Endpoints

### 1. Login
**Endpoint:** `POST /LoginServlet`

**Description:** Authenticates user credentials and creates session

**Request Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| email | String | Yes | User's email address |
| password | String | Yes | User's password (plain text) |
| role | String | Yes | User role: `customer`, `vendor`, or `admin` |

**Request Example:**
```http
POST /VendorFlow/LoginServlet HTTP/1.1
Content-Type: application/x-www-form-urlencoded

email=ravi@vendorflow.com&password=vendor123&role=vendor
```

**Success Response (HTTP 302):**
- Redirects to role-specific dashboard:
  - `customer/dashboard.jsp` - Customer
  - `vendor/dashboard.jsp` - Vendor
  - `admin/dashboard.jsp` - Admin

**Error Response (HTTP 200):**
- Returns to login page with error message
- Error displayed in `error` request attribute

**Error Conditions:**
- `400`: Missing required parameters
- `401`: Invalid credentials or role mismatch
- `500`: Database connection error

---

### 2. Register
**Endpoint:** `POST /RegisterServlet`

**Description:** Creates a new user account

**Request Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| name | String | Yes | Full name |
| email | String | Yes | Email address (must be unique) |
| password | String | Yes | Password (plain text) |
| phone | String | No | Phone number |
| role | String | Yes | Role: `customer` or `vendor` |
| shop_name | String | No | Shop name (vendors only) |
| shop_address | String | No | Shop address (vendors only) |

**Request Example:**
```http
POST /VendorFlow/RegisterServlet HTTP/1.1
Content-Type: application/x-www-form-urlencoded

name=Ravi+Kumar&email=ravi@vendor.com&password=pass123&role=vendor&shop_name=Ravi+Juice+Center
```

**Success Response (HTTP 302):**
- Redirects to login page with success message
- Success displayed in `success` request attribute

**Error Response (HTTP 200):**
- Returns to registration page with error
- Error displayed in `error` request attribute

**Error Conditions:**
- `400`: Missing required parameters
- `409`: Email already exists
- `500`: Database error

---

### 3. Logout
**Endpoint:** `GET /LogoutServlet`

**Description:** Invalidates user session and logs out

**Request Parameters:** None

**Authentication:** Required (any role)

**Success Response (HTTP 302):**
- Invalidates current session
- Redirects to `login.jsp`

---

## Customer Endpoints

### 4. Browse Menu
**Endpoint:** `GET /customer/menu.jsp`

**Description:** Displays available menu items for browsing

**Authentication:** Required (Customer role)

**Request Parameters:** None

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| vendor_id | Integer | No | Filter by vendor (not implemented) |
| category | String | No | Filter by category (not implemented) |

**Success Response (HTTP 200):**
- Renders menu items in JSP
- Menu items fetched via MenuDAO

**Error Conditions:**
- `401`: Not authenticated or wrong role
- `500`: Database error

---

### 5. Add to Cart
**Endpoint:** `POST /CartServlet`

**Description:** Adds item to shopping cart stored in session

**Authentication:** Required (Customer role)

**Request Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| action | String | Yes | Action: `add`, `update`, `remove`, `clear` |
| menu_item_id | Integer | No | Menu item ID (required for add/update/remove) |
| quantity | Integer | No | Quantity (required for add/update, default: 1) |

**Request Example:**
```http
POST /VendorFlow/CartServlet HTTP/1.1
Content-Type: application/x-www-form-urlencoded

action=add&menu_item_id=1&quantity=2
```

**Success Response (HTTP 302):**
- Redirects to cart page: `customer/cart.jsp`
- Cart stored in HttpSession under key `cart`

**Error Conditions:**
- `400`: Invalid action or missing parameters
- `401`: Not authenticated or wrong role
- `404`: Menu item not found

---

### 6. View Cart
**Endpoint:** `GET /customer/cart.jsp`

**Description:** Displays current shopping cart

**Authentication:** Required (Customer role)

**Request Parameters:** None

**Success Response (HTTP 200):**
- Renders cart items from session
- Calculates totals

**Error Conditions:**
- `401`: Not authenticated or wrong role

---

### 7. Place Order
**Endpoint:** `POST /PlaceOrderServlet`

**Description:** Creates new order from cart with token generation

**Authentication:** Required (Customer role)

**Request Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| specialNotes | String | No | Special instructions for vendor |

**Process Flow:**
1. Validates customer session
2. Retrieves cart from session
3. Calculates total amount
4. Generates token number (FCFS per vendor per day)
5. Creates order header (status: Pending)
6. Creates order items from cart
7. Creates payment record (Cash, Pending)
8. Commits transaction
9. Clears cart from session
10. Redirects to token status page

**Request Example:**
```http
POST /VendorFlow/PlaceOrderServlet HTTP/1.1
Content-Type: application/x-www-form-urlencoded

specialNotes=No+ice+please
```

**Success Response (HTTP 302):**
- Redirects to: `/customer/tokenStatus.jsp?orderId={id}&token={number}`
- Order created in database
- Cart cleared from session

**Error Response (HTTP 302):**
- Redirects to cart page with error: `customer/cart.jsp?error=Order+failed`

**Error Conditions:**
- `400`: Cart is empty or invalid
- `401`: Not authenticated or wrong role
- `500`: Database error, transaction rollback

**Transaction Properties:**
- Atomic: All-or-nothing
- Isolated: Other queries cannot see partial results
- Consistent: All constraints satisfied
- Durable: Committed to database

---

### 8. Token Status
**Endpoint:** `GET /customer/tokenStatus.jsp`

**Description:** Displays real-time status of customer's order

**Authentication:** Required (Customer role)

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| orderId | Integer | Yes | Order ID |
| token | Integer | Yes | Token number (for display) |

**Request Example:**
```http
GET /VendorFlow/customer/tokenStatus.jsp?orderId=123&token=5
```

**Success Response (HTTP 200):**
- Renders order status (Pending/Preparing/Ready/Completed)
- Shows token number
- Displays vendor information
- Shows estimated wait time (static)

**Error Conditions:**
- `400`: Missing orderId or token
- `401`: Not authenticated or wrong role
- `403`: Order does not belong to customer
- `404`: Order not found

---

### 9. Order History
**Endpoint:** `GET /customer/history.jsp`

**Description:** Displays customer's order history

**Authentication:** Required (Customer role)

**Request Parameters:** None

**Success Response (HTTP 200):**
- Lists all orders for customer (newest first)
- Shows status, total amount, date
- Links to feedback for completed orders

**Error Conditions:**
- `401`: Not authenticated or wrong role
- `500`: Database error

---

### 10. Submit Feedback
**Endpoint:** `POST /FeedbackServlet`

**Description:** Submits rating and comments for completed order

**Authentication:** Required (Customer role)

**Request Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| orderId | Integer | Yes | Completed order ID |
| rating | Integer | Yes | Rating: 1-5 |
| comments | String | No | Feedback comments |

**Request Example:**
```http
POST /VendorFlow/FeedbackServlet HTTP/1.1
Content-Type: application/x-www-form-urlencoded

orderId=123&rating=5&comments=Great+service%21
```

**Success Response (HTTP 302):**
- Redirects to order history with success message
- Feedback saved in database

**Error Conditions:**
- `400`: Invalid rating (not 1-5) or missing orderId
- `401`: Not authenticated or wrong role
- `403`: Order does not belong to customer
- `404`: Order not found or not completed
- `409`: Feedback already submitted for this order

---

## Vendor Endpoints

### 11. Vendor Dashboard
**Endpoint:** `GET /vendor/dashboard.jsp`

**Description:** Vendor's main control panel

**Authentication:** Required (Vendor role)

**Request Parameters:** None

**Success Response (HTTP 200):**
- Displays vendor-specific metrics
- Recent orders summary
- Quick access to queue and menu management

**Error Conditions:**
- `401`: Not authenticated or wrong role

---

### 12. Live Queue
**Endpoint:** `GET /QueueServlet`

**Description:** Displays today's active orders (FCFS)

**Authentication:** Required (Vendor role)

**Query Parameters:** None

**Success Response (HTTP 200):**
- Renders queue page with today's orders
- Orders filtered by:
  - Vendor ID (from session)
  - Status IN ('Pending', 'Preparing', 'Ready')
  - Created today (DATE(created_at) = CURRENT_DATE)
- Sorted by token_number ASC
- Auto-refreshes every 15 seconds (meta refresh)

**Error Conditions:**
- `401`: Not authenticated or wrong role
- `500`: Database error

---

### 13. Update Order Status
**Endpoint:** `POST /OrderStatusServlet`

**Description:** Updates order status (state machine)

**Authentication:** Required (Vendor role)

**Request Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| orderId | Integer | Yes | Order to update |
| status | String | Yes | New status: `Preparing`, `Ready`, `Completed`, `Cancelled` |
| from | String | No | Source page (e.g., "queue") |

**Status Transitions:**
```
Pending → Preparing → Ready → Completed
         ↓
      Cancelled (anytime)
```

**Request Example:**
```http
POST /VendorFlow/OrderStatusServlet HTTP/1.1
Content-Type: application/x-www-form-urlencoded

orderId=123&status=Ready&from=queue
```

**Success Response (HTTP 302):**
- Redirects to queue page (or source page if specified)
- Success message displayed

**Error Conditions:**
- `400`: Invalid status or missing parameters
- `401`: Not authenticated or wrong role
- `403`: Order does not belong to vendor
- `404`: Order not found
- `409`: Invalid status transition (e.g., Completed → Preparing)

---

### 14. Manage Menu (List)
**Endpoint:** `GET /vendor/manageMenu.jsp`

**Description:** Lists vendor's menu items with CRUD options

**Authentication:** Required (Vendor role)

**Request Parameters:** None

**Success Response (HTTP 200):**
- Lists all menu items for vendor
- Shows availability status
- Provides edit/delete toggles

**Error Conditions:**
- `401`: Not authenticated or wrong role
- `500`: Database error

---

### 15. Add Menu Item
**Endpoint:** `POST /AddMenuServlet`

**Description:** Creates new menu item

**Authentication:** Required (Vendor role)

**Request Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| name | String | Yes | Item name |
| description | String | No | Item description |
| price | Decimal | Yes | Price (≥0) |
| category | String | No | Category (default: "General") |

**Request Example:**
```http
POST /VendorFlow/AddMenuServlet HTTP/1.1
Content-Type: application/x-www-form-urlencoded

name=Mango+Smoothie&price=45.00&category=Shake
```

**Success Response (HTTP 302):**
- Redirects to manageMenu.jsp with success message
- New item available immediately

**Error Conditions:**
- `400`: Missing required fields or invalid price
- `401`: Not authenticated or wrong role
- `500`: Database error

---

### 16. Update Menu Item
**Endpoint:** `POST /UpdateMenuServlet`

**Description:** Updates existing menu item

**Authentication:** Required (Vendor role)

**Request Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | Integer | Yes | Menu item ID |
| name | String | No | New name |
| description | String | No | New description |
| price | Decimal | No | New price (≥0) |
| category | String | No | New category |
| is_available | Boolean | No | Availability toggle |

**Request Example:**
```http
POST /VendorFlow/UpdateMenuServlet HTTP/1.1
Content-Type: application/x-www-form-urlencoded

id=1&price=50.00&is_available=false
```

**Success Response (HTTP 302):**
- Redirects to manageMenu.jsp with success message
- Changes reflected immediately

**Error Conditions:**
- `400`: Invalid parameters
- `401`: Not authenticated or wrong role
- `403`: Item does not belong to vendor
- `404`: Item not found
- `500`: Database error

---

### 17. Delete Menu Item
**Endpoint:** `POST /DeleteMenuServlet`

**Description:** Soft deletes menu item (sets is_available=false)

**Authentication:** Required (Vendor role)

**Request Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | Integer | Yes | Menu item ID |

**Request Example:**
```http
POST /VendorFlow/DeleteMenuServlet HTTP/1.1
Content-Type: application/x-www-form-urlencoded

id=1
```

**Success Response (HTTP 302):**
- Redirects to manageMenu.jsp
- Item hidden from customer menu

**Error Conditions:**
- `400`: Missing ID
- `401`: Not authenticated or wrong role
- `403`: Item does not belong to vendor
- `404`: Item not found
- `409`: Item referenced in existing orders

---

### 18. View Orders (All)
**Endpoint:** `GET /vendor/orders.jsp`

**Description:** Lists all orders for vendor (including completed)

**Authentication:** Required (Vendor role)

**Request Parameters:** None

**Success Response (HTTP 200):**
- Lists all orders for vendor (newest first)
- Shows status, total, date, customer

**Error Conditions:**
- `401`: Not authenticated or wrong role
- `500`: Database error

---

### 19. Analytics Dashboard
**Endpoint:** `GET /vendor/analytics.jsp`

**Description:** Displays sales analytics and insights

**Authentication:** Required (Vendor role)

**Request Parameters:** None

**Success Response (HTTP 200):**
- Revenue charts
- Popular items
- Order trends

**Error Conditions:**
- `401`: Not authenticated or wrong role
- `500`: Database error

---

### 20. View Analytics Data (JSON)
**Endpoint:** `GET /AnalyticsServlet`

**Description:** Returns analytics data as JSON for charts

**Authentication:** Required (Vendor role)

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| type | String | No | Data type: `revenue`, `popular`, `trends` |

**Success Response (HTTP 200):**
```json
{
  "status": "success",
  "data": {
    "labels": ["Mon", "Tue", "Wed"],
    "values": [1500, 2300, 1800]
  }
}
```

**Error Response (HTTP 400):**
```json
{
  "status": "error",
  "message": "Invalid type parameter"
}
```

**Error Conditions:**
- `401`: Not authenticated or wrong role
- `400`: Invalid type parameter
- `500`: Database error

---

### 21. Vendor Profile
**Endpoint:** `GET /vendor/profile.jsp`

**Description:** View and edit vendor profile

**Authentication:** Required (Vendor role)

**Request Parameters:** None

**Success Response (HTTP 200):**
- Displays vendor information
- Edit form for profile updates

**Error Conditions:**
- `401`: Not authenticated or wrong role

---

### 22. Update Profile
**Endpoint:** `POST` (via UserDAO.updateProfile())

**Description:** Updates vendor profile information

**Authentication:** Required (Vendor role)

**Request Body Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| name | String | Yes | Vendor name |
| phone | String | No | Phone number |
| shop_name | String | No | Shop name |
| shop_address | String | No | Shop address |

**Success Response:**
- Profile updated successfully
- Redirects to profile page

**Error Conditions:**
- `400`: Missing name
- `401`: Not authenticated or wrong role
- `500`: Database error

---

## Admin Endpoints

### 23. Admin Dashboard
**Endpoint:** `GET /admin/dashboard.jsp`

**Description:** System administration dashboard

**Authentication:** Required (Admin role)

**Request Parameters:** None

**Success Response (HTTP 200):**
- System overview
- User statistics
- Vendor listings

**Error Conditions:**
- `401`: Not authenticated or wrong role

---

## Response Status Codes

| Code | Description |
|------|-------------|
| 200 | Success - Page rendered or operation completed |
| 302 | Redirect - Success with redirect to another page |
| 400 | Bad Request - Invalid parameters or input |
| 401 | Unauthorized - Authentication required or failed |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 409 | Conflict - Resource conflict or validation error |
| 500 | Internal Server Error - Database or system error |

---

## Error Response Format

Errors are communicated via:
1. **Request Attributes**: `error` or `message` attribute
2. **URL Parameters**: `?error=message` (URL encoded)
3. **JSP Rendering**: Error messages displayed in alert boxes
4. **JSON Response**: For AnalyticsServlet

**Example Error Display:**
```html
<div class="alert alert-danger">
    Invalid email, password, or role. Please try again.
</div>
```

---

## Rate Limiting

**Current Implementation:** None

**Recommendation:** Implement rate limiting for:
- Login endpoint (prevent brute force)
- Registration endpoint (prevent spam)
- API endpoints (prevent abuse)

---

## API Versioning

**Current Implementation:** None (all endpoints are version-less)

**Recommendation:** Add version prefix to endpoints:
- `/v1/LoginServlet`
- `/v1/PlaceOrderServlet`
- etc.

---

## Authentication Best Practices

### Current Implementation
- Session-based authentication
- Role-based access control
- Password stored in plaintext (⚠️ security risk)

### Recommended Improvements
1. Hash passwords with bcrypt or Argon2
2. Implement HTTPS/TLS
3. Add CSRF token protection
4. Implement password strength requirements
5. Add account lockout after failed attempts
6. Implement session regeneration on login
7. Add "Remember Me" functionality with secure cookies

---

## Testing Endpoints

### Using cURL

**Login:**
```bash
curl -X POST http://localhost:8080/VendorFlow/LoginServlet \
  -d "email=ravi@vendorflow.com&password=vendor123&role=vendor" \
  -v -L -c cookies.txt
```

**Place Order:**
```bash
curl -X POST http://localhost:8080/VendorFlow/PlaceOrderServlet \
  -d "specialNotes=No+ice" \
  -b cookies.txt \
  -v -L
```

**Get Queue (JSON):**
```bash
curl http://localhost:8080/VendorFlow/AnalyticsServlet?type=popular \
  -b cookies.txt \
  -H "Accept: application/json"
```

---

## Future API Enhancements

1. **RESTful API**: JSON-based API for mobile applications
2. **WebSocket Support**: Real-time queue updates
3. **Webhook Support**: Notifications for order status changes
4. **OAuth2 Integration**: Third-party authentication
5. **API Key System**: For third-party integrations
6. **GraphQL Endpoint**: Flexible data querying
7. **Pagination**: For large datasets
8. **Filtering and Sorting**: Query parameters for lists
9. **Field Selection**: Select specific fields in responses
10. **Rate Limiting Headers**: Inform clients of limits

---

*Last Updated: 2026-05-07*
*API Version: 1.0 (Legacy)*
