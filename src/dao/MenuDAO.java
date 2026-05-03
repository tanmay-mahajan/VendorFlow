package dao;

import model.MenuItem;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * MenuDAO – CRUD operations for menu_items table.
 */
public class MenuDAO {

    /** Get all available menu items for a specific vendor. */
    public List<MenuItem> getMenuByVendor(int vendorId) {
        List<MenuItem> list = new ArrayList<>();
        String sql = "SELECT * FROM menu_items WHERE vendor_id = ? ORDER BY category, name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vendorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));

        } catch (SQLException e) {
            System.err.println("[MenuDAO.getMenuByVendor] " + e.getMessage());
        }
        return list;
    }

    /** Get all available menu items across all vendors (for customer browse). */
    public List<MenuItem> getAllAvailableMenuItems() {
        List<MenuItem> list = new ArrayList<>();
        String sql = "SELECT mi.*, u.shop_name AS vendor_shop_name " +
                     "FROM menu_items mi " +
                     "JOIN users u ON mi.vendor_id = u.id " +
                     "WHERE mi.is_available = TRUE " +
                     "ORDER BY u.shop_name, mi.category, mi.name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                MenuItem item = mapRow(rs);
                item.setVendorShopName(rs.getString("vendor_shop_name"));
                list.add(item);
            }

        } catch (SQLException e) {
            System.err.println("[MenuDAO.getAllAvailableMenuItems] " + e.getMessage());
        }
        return list;
    }

    /** Get a single menu item by ID. */
    public MenuItem getMenuItemById(int id) {
        String sql = "SELECT * FROM menu_items WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);

        } catch (SQLException e) {
            System.err.println("[MenuDAO.getMenuItemById] " + e.getMessage());
        }
        return null;
    }

    /** Add a new menu item. Returns generated id or -1. */
    public int addMenuItem(MenuItem item) {
        String sql = "INSERT INTO menu_items (vendor_id, name, description, price, category, is_available) " +
                     "VALUES (?, ?, ?, ?, ?, ?) RETURNING id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, item.getVendorId());
            ps.setString(2, item.getName());
            ps.setString(3, item.getDescription());
            ps.setDouble(4, item.getPrice());
            ps.setString(5, item.getCategory());
            ps.setBoolean(6, item.isAvailable());

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id");

        } catch (SQLException e) {
            System.err.println("[MenuDAO.addMenuItem] " + e.getMessage());
        }
        return -1;
    }

    /** Update an existing menu item. */
    public boolean updateMenuItem(MenuItem item) {
        String sql = "UPDATE menu_items SET name=?, description=?, price=?, category=?, is_available=? " +
                     "WHERE id=? AND vendor_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getName());
            ps.setString(2, item.getDescription());
            ps.setDouble(3, item.getPrice());
            ps.setString(4, item.getCategory());
            ps.setBoolean(5, item.isAvailable());
            ps.setInt(6, item.getId());
            ps.setInt(7, item.getVendorId());
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[MenuDAO.updateMenuItem] " + e.getMessage());
        }
        return false;
    }

    /** Delete a menu item (only if it belongs to the vendor). */
    public boolean deleteMenuItem(int itemId, int vendorId) {
        String sql = "DELETE FROM menu_items WHERE id=? AND vendor_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, itemId);
            ps.setInt(2, vendorId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[MenuDAO.deleteMenuItem] " + e.getMessage());
        }
        return false;
    }

    private MenuItem mapRow(ResultSet rs) throws SQLException {
        MenuItem m = new MenuItem();
        m.setId(rs.getInt("id"));
        m.setVendorId(rs.getInt("vendor_id"));
        m.setName(rs.getString("name"));
        m.setDescription(rs.getString("description"));
        m.setPrice(rs.getDouble("price"));
        m.setCategory(rs.getString("category"));
        m.setAvailable(rs.getBoolean("is_available"));
        m.setCreatedAt(rs.getString("created_at"));
        return m;
    }
}
