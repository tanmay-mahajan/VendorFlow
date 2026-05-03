# VendorFlow 🚀

**VendorFlow** is a comprehensive **Smart Vendor Queue and Order Management System** designed to streamline operations for food vendors, cafeterias, and restaurants. It bridges the gap between customers and vendors by providing a seamless, real-time platform for ordering, queue tracking, and business analytics.

## 🌟 Key Features

### 👤 Customer Features
* **Live Menu Browsing:** View available items, categories, and dynamic pricing.
* **Shopping Cart & Checkout:** Easily add items to cart and place orders.
* **Real-time Queue Tracking:** Check live order status (Pending, Preparing, Completed) and token numbers.
* **Feedback System:** Rate and leave comments on orders to help vendors improve.

### 🏪 Vendor Features
* **Menu Management:** Add, update, delete, and toggle the availability of menu items.
* **Order Queue Dashboard:** Manage incoming orders, update their status, and notify customers instantly.
* **Analytics & Insights:** View sales trends, popular items, and revenue charts directly from the dashboard.
* **Review Management:** Read customer feedback and ratings.

### 🛡️ Admin/System Features
* **Role-based Access Control:** Secure login and authentication for Customers, Vendors, and Admins.
* **Database Integration:** Persistent and reliable data storage.
* **REST-like Endpoints:** Servlets power the backend APIs to handle JSON data for dynamic dashboards (using `Gson`).

## 🛠️ Technology Stack
* **Backend:** Java, Servlets, JSP
* **Frontend:** HTML5, CSS3, JavaScript (Vanilla/ES6)
* **Database:** Relational Database (PostgreSQL / MySQL) via JDBC
* **Server:** Apache Tomcat 9.x
* **Data Processing:** Google Gson (for JSON handling)

## ⚙️ Installation & Setup

### Prerequisites
* **Java Development Kit (JDK):** Version 11 or higher
* **Apache Tomcat:** Version 9.x
* **Database:** PostgreSQL or MySQL installed and running

### Steps to Run Locally

1. **Clone the repository**
   ```bash
   git clone https://github.com/tanmay-mahajan/VendorFlow.git
   cd VendorFlow
   ```

2. **Set up the Database**
   * Create a new database named `vendorflow`.
   * Import the provided `vendorflow.sql` file into your database to create the required tables and seed data.
   * *Update `src/util/DBConnection.java` with your database username and password if necessary.*

3. **Compile the Source Code**
   * You can compile the project using your IDE (Eclipse/IntelliJ) by importing it as a "Dynamic Web Project".
   * Alternatively, use the command line to compile the `.java` files into the `WebContent/WEB-INF/classes` folder, ensuring Tomcat's `servlet-api.jar` and the database driver are in your classpath.

4. **Deploy to Tomcat**
   * Copy the `WebContent` folder into your Tomcat `webapps` directory and rename it to `VendorFlow`.
   * Start Tomcat by running `startup.bat` (Windows) or `startup.sh` (Mac/Linux) from the Tomcat `bin` folder.

5. **Access the Application**
   * Open your web browser and navigate to: `http://localhost:8080/VendorFlow`

## 🤝 Contributing
Contributions, issues, and feature requests are welcome!
Feel free to check [issues page](https://github.com/tanmay-mahajan/VendorFlow/issues) if you want to contribute.

## 📝 License
This project is open-source and available under the [MIT License](LICENSE).
