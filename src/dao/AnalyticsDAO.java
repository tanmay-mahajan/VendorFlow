package dao;

import util.DBConnection;

import java.sql.*;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * AnalyticsDAO – aggregated statistics for the vendor analytics dashboard.
 */
public class AnalyticsDAO {

    /** Total orders placed with this vendor. */
    public int getTotalOrders(int vendorId) {
        return queryInt("SELECT COUNT(*) FROM orders WHERE vendor_id=?", vendorId);
    }

    /** Total revenue earned (only Completed orders). */
    public double getTotalRevenue(int vendorId) {
        return queryDouble(
            "SELECT COALESCE(SUM(o.total_amount),0) FROM orders o " +
            "WHERE o.vendor_id=? AND o.status='Completed'", vendorId);
    }

    /** Revenue for today only. */
    public double getTodayRevenue(int vendorId) {
        return queryDouble(
            "SELECT COALESCE(SUM(total_amount),0) FROM orders " +
            "WHERE vendor_id=? AND status='Completed' AND DATE(created_at)=CURRENT_DATE", vendorId);
    }

    /** Count of pending orders today. */
    public int getPendingOrders(int vendorId) {
        return queryInt(
            "SELECT COUNT(*) FROM orders WHERE vendor_id=? AND status='Pending' AND DATE(created_at)=CURRENT_DATE",
            vendorId);
    }

    /** Count of completed orders today. */
    public int getCompletedOrders(int vendorId) {
        return queryInt(
            "SELECT COUNT(*) FROM orders WHERE vendor_id=? AND status='Completed' AND DATE(created_at)=CURRENT_DATE",
            vendorId);
    }

    /** Total unique customers who ordered from this vendor. */
    public int getTotalCustomers(int vendorId) {
        return queryInt(
            "SELECT COUNT(DISTINCT customer_id) FROM orders WHERE vendor_id=?", vendorId);
    }

    /**
     * Orders per day-of-week (Mon–Sun) for current week.
     * Returns a Map: {"Mon"->3, "Tue"->5, ...}
     */
    public Map<String, Integer> getOrdersPerDayOfWeek(int vendorId) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String[] days = {"Mon","Tue","Wed","Thu","Fri","Sat","Sun"};
        for (String d : days) map.put(d, 0);

        String sql = "SELECT TO_CHAR(created_at,'Dy') AS day_name, COUNT(*) AS cnt " +
                     "FROM orders WHERE vendor_id=? " +
                     "  AND created_at >= DATE_TRUNC('week', CURRENT_DATE) " +
                     "GROUP BY TO_CHAR(created_at,'Dy'), EXTRACT(DOW FROM created_at) " +
                     "ORDER BY EXTRACT(DOW FROM created_at)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vendorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String dayName = rs.getString("day_name"); // "Mon", "Tue" etc.
                int    cnt     = rs.getInt("cnt");
                // Normalize to our 3-char keys
                for (String key : days) {
                    if (dayName.startsWith(key.substring(0,2))) { map.put(key, cnt); break; }
                }
            }

        } catch (SQLException e) {
            System.err.println("[AnalyticsDAO.getOrdersPerDayOfWeek] " + e.getMessage());
        }
        return map;
    }

    /**
     * Top 5 most-sold items for a vendor.
     * Returns Map: {"Lime Juice"->12, ...}
     */
    public Map<String, Integer> getTopItems(int vendorId) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT mi.name, SUM(oi.quantity) AS total_sold " +
                     "FROM order_items oi " +
                     "JOIN menu_items mi ON oi.menu_item_id = mi.id " +
                     "WHERE mi.vendor_id=? " +
                     "GROUP BY mi.name ORDER BY total_sold DESC LIMIT 5";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vendorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) map.put(rs.getString("name"), rs.getInt("total_sold"));

        } catch (SQLException e) {
            System.err.println("[AnalyticsDAO.getTopItems] " + e.getMessage());
        }
        return map;
    }

    /**
     * Orders by hour (peak-hour analysis).
     * Returns Map: {"8AM"->2, "9AM"->5, ...} for today.
     */
    public Map<String, Integer> getPeakHours(int vendorId) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT EXTRACT(HOUR FROM created_at) AS hr, COUNT(*) AS cnt " +
                     "FROM orders WHERE vendor_id=? AND DATE(created_at)=CURRENT_DATE " +
                     "GROUP BY hr ORDER BY hr";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vendorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int hr = rs.getInt("hr");
                String label = (hr == 0 ? "12AM" : (hr < 12 ? hr + "AM" : (hr == 12 ? "12PM" : (hr-12) + "PM")));
                map.put(label, rs.getInt("cnt"));
            }

        } catch (SQLException e) {
            System.err.println("[AnalyticsDAO.getPeakHours] " + e.getMessage());
        }
        return map;
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private int queryInt(String sql, int vendorId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vendorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("[AnalyticsDAO.queryInt] " + e.getMessage());
        }
        return 0;
    }

    private double queryDouble(String sql, int vendorId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vendorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) {
            System.err.println("[AnalyticsDAO.queryDouble] " + e.getMessage());
        }
        return 0.0;
    }
}
