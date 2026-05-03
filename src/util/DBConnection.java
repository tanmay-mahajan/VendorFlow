package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection – utility class to get a PostgreSQL JDBC connection.
 *
 * SETUP INSTRUCTIONS:
 *   1. Make sure PostgreSQL is running on localhost:5432
 *   2. Create database:  CREATE DATABASE vendorflow;
 *   3. Run vendorflow.sql in pgAdmin Query Tool
 *   4. Change DB_USER / DB_PASS below to match your credentials
 *   5. Add postgresql-42.x.x.jar to WEB-INF/lib
 */
public class DBConnection {

    // ── Change these to match your PostgreSQL setup ──────────────────────────
    private static final String DB_URL  = "jdbc:postgresql://localhost:5432/vendorflow";
    private static final String DB_USER = "postgres";
    private static final String DB_PASS = "postgres";   // ← your pg password
    // ─────────────────────────────────────────────────────────────────────────

    static {
        try {
            // Register PostgreSQL JDBC driver
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                "PostgreSQL JDBC Driver not found. Add postgresql-42.x.x.jar to WEB-INF/lib.\n" + e);
        }
    }

    /**
     * Returns a new Connection to the vendorflow database.
     * Caller is responsible for closing the connection.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }
}
