package dao;

import model.Order;
import model.OrderItem;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * OrderDAO – place orders, retrieve queue, update status.
 */
public class OrderDAO {

    /**
     * Place a new order.
     * Inserts order header + order_items in a single transaction.
     * Returns the generated order ID, or -1 on failure.
     */
    public int placeOrder(Order order) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Insert order header
            String orderSql = "INSERT INTO orders (customer_id, vendor_id, token_number, " +
                              "total_amount, status, special_notes) VALUES (?,?,?,?,?,?) RETURNING id";
            int orderId = -1;

            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setInt(1, order.getCustomerId());
                ps.setInt(2, order.getVendorId());
                ps.setInt(3, order.getTokenNumber());
                ps.setDouble(4, order.getTotalAmount());
                ps.setString(5, "Pending");
                ps.setString(6, order.getSpecialNotes());

                ResultSet rs = ps.executeQuery();
                if (rs.next()) orderId = rs.getInt("id");
            }

            if (orderId < 0) { conn.rollback(); return -1; }

            // 2. Insert order items
            String itemSql = "INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) " +
                             "VALUES (?,?,?,?)";
            try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
                for (OrderItem item : order.getItems()) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, item.getMenuItemId());
                    ps.setInt(3, item.getQuantity());
                    ps.setDouble(4, item.getUnitPrice());
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // 3. Insert payment record (Cash, Pending)
            String paymentSql = "INSERT INTO payments (order_id, amount, payment_method, payment_status) " +
                                "VALUES (?,?,'Cash','Pending')";
            try (PreparedStatement ps = conn.prepareStatement(paymentSql)) {
                ps.setInt(1, orderId);
                ps.setDouble(2, order.getTotalAmount());
                ps.executeUpdate();
            }

            conn.commit();
            return orderId;

        } catch (SQLException e) {
            System.err.println("[OrderDAO.placeOrder] " + e.getMessage());
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { /* ignore */ }
            return -1;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } }
            catch (SQLException ex) { /* ignore */ }
        }
    }

    /** Get all orders for a customer (history), newest first. */
    public List<Order> getOrdersByCustomer(int customerId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.shop_name AS vendor_shop_name " +
                     "FROM orders o JOIN users u ON o.vendor_id = u.id " +
                     "WHERE o.customer_id = ? ORDER BY o.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = mapRow(rs);
                o.setVendorShopName(rs.getString("vendor_shop_name"));
                list.add(o);
            }

        } catch (SQLException e) {
            System.err.println("[OrderDAO.getOrdersByCustomer] " + e.getMessage());
        }
        return list;
    }

    /**
     * Get the vendor queue – all non-completed orders for a vendor today,
     * ordered by token_number (FCFS).
     */
    public List<Order> getVendorQueue(int vendorId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.name AS customer_name " +
                     "FROM orders o JOIN users u ON o.customer_id = u.id " +
                     "WHERE o.vendor_id = ? " +
                     "  AND o.status NOT IN ('Completed','Cancelled') " +
                     "  AND DATE(o.created_at) = CURRENT_DATE " +
                     "ORDER BY o.token_number ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vendorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = mapRow(rs);
                o.setCustomerName(rs.getString("customer_name"));
                list.add(o);
            }

        } catch (SQLException e) {
            System.err.println("[OrderDAO.getVendorQueue] " + e.getMessage());
        }
        return list;
    }

    /** Get all orders for a vendor (for the orders page), newest first. */
    public List<Order> getAllOrdersForVendor(int vendorId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.name AS customer_name " +
                     "FROM orders o JOIN users u ON o.customer_id = u.id " +
                     "WHERE o.vendor_id = ? ORDER BY o.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vendorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = mapRow(rs);
                o.setCustomerName(rs.getString("customer_name"));
                list.add(o);
            }

        } catch (SQLException e) {
            System.err.println("[OrderDAO.getAllOrdersForVendor] " + e.getMessage());
        }
        return list;
    }

    /** Update the status of an order. */
    public boolean updateOrderStatus(int orderId, String status) {
        String sql = "UPDATE orders SET status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[OrderDAO.updateOrderStatus] " + e.getMessage());
        }
        return false;
    }

    /** Get order by ID (with items). */
    public Order getOrderById(int orderId) {
        String sql = "SELECT o.*, u.name AS customer_name, v.shop_name AS vendor_shop_name " +
                     "FROM orders o " +
                     "JOIN users u ON o.customer_id = u.id " +
                     "JOIN users v ON o.vendor_id   = v.id " +
                     "WHERE o.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order o = mapRow(rs);
                o.setCustomerName(rs.getString("customer_name"));
                o.setVendorShopName(rs.getString("vendor_shop_name"));
                o.setItems(getOrderItems(orderId));
                return o;
            }

        } catch (SQLException e) {
            System.err.println("[OrderDAO.getOrderById] " + e.getMessage());
        }
        return null;
    }

    /** Get line items for an order. */
    public List<OrderItem> getOrderItems(int orderId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.*, mi.name AS menu_item_name " +
                     "FROM order_items oi JOIN menu_items mi ON oi.menu_item_id = mi.id " +
                     "WHERE oi.order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderItem oi = new OrderItem();
                oi.setId(rs.getInt("id"));
                oi.setOrderId(orderId);
                oi.setMenuItemId(rs.getInt("menu_item_id"));
                oi.setQuantity(rs.getInt("quantity"));
                oi.setUnitPrice(rs.getDouble("unit_price"));
                oi.setSubtotal(rs.getDouble("subtotal"));
                oi.setMenuItemName(rs.getString("menu_item_name"));
                items.add(oi);
            }

        } catch (SQLException e) {
            System.err.println("[OrderDAO.getOrderItems] " + e.getMessage());
        }
        return items;
    }

    /** Get live token status for a customer – most recent order for this vendor today. */
    public Order getTokenStatus(int customerId, int orderId) {
        String sql = "SELECT o.*, v.shop_name AS vendor_shop_name " +
                     "FROM orders o JOIN users v ON o.vendor_id = v.id " +
                     "WHERE o.id = ? AND o.customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Order o = mapRow(rs);
                o.setVendorShopName(rs.getString("vendor_shop_name"));
                return o;
            }

        } catch (SQLException e) {
            System.err.println("[OrderDAO.getTokenStatus] " + e.getMessage());
        }
        return null;
    }

    private Order mapRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("id"));
        o.setCustomerId(rs.getInt("customer_id"));
        o.setVendorId(rs.getInt("vendor_id"));
        o.setTokenNumber(rs.getInt("token_number"));
        o.setTotalAmount(rs.getDouble("total_amount"));
        o.setStatus(rs.getString("status"));
        o.setSpecialNotes(rs.getString("special_notes"));
        o.setCreatedAt(rs.getString("created_at"));
        o.setUpdatedAt(rs.getString("updated_at"));
        return o;
    }
}
