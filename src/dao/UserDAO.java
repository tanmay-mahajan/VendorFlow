package dao;

import model.User;
import util.DBConnection;

import java.sql.*;

/**
 * UserDAO – database operations for the users table.
 */
public class UserDAO {

    /**
     * Register a new user. Returns the generated id, or -1 on failure.
     */
    public int registerUser(User user) {
        String sql = "INSERT INTO users (name, email, password, phone, role, shop_name, shop_address) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getRole());
            ps.setString(6, user.getShopName());
            ps.setString(7, user.getShopAddress());

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id");

        } catch (SQLException e) {
            System.err.println("[UserDAO.registerUser] " + e.getMessage());
        }
        return -1;
    }

    /**
     * Login validation – match email + password + role.
     * Returns the User object if found, null otherwise.
     */
    public User loginUser(String email, String password, String role) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ? AND role = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);
            ps.setString(3, role);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);

        } catch (SQLException e) {
            System.err.println("[UserDAO.loginUser] " + e.getMessage());
        }
        return null;
    }

    /** Check if an email already exists (used during registration). */
    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            System.err.println("[UserDAO.emailExists] " + e.getMessage());
        }
        return false;
    }

    /** Get a user by ID. */
    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);

        } catch (SQLException e) {
            System.err.println("[UserDAO.getUserById] " + e.getMessage());
        }
        return null;
    }

    /** Update vendor profile (name, phone, shop_name, shop_address). */
    public boolean updateProfile(User user) {
        String sql = "UPDATE users SET name=?, phone=?, shop_name=?, shop_address=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getShopName());
            ps.setString(4, user.getShopAddress());
            ps.setInt(5, user.getId());
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[UserDAO.updateProfile] " + e.getMessage());
        }
        return false;
    }

    /** Map a ResultSet row to a User object. */
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setName(rs.getString("name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setPhone(rs.getString("phone"));
        u.setRole(rs.getString("role"));
        u.setShopName(rs.getString("shop_name"));
        u.setShopAddress(rs.getString("shop_address"));
        u.setCreatedAt(rs.getString("created_at"));
        return u;
    }
}
