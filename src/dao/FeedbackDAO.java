package dao;

import model.Feedback;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * FeedbackDAO – submit and retrieve customer feedback.
 */
public class FeedbackDAO {

    /** Submit a feedback record. Returns true on success. */
    public boolean submitFeedback(Feedback fb) {
        String sql = "INSERT INTO feedback (customer_id, vendor_id, order_id, rating, comments) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, fb.getCustomerId());
            ps.setInt(2, fb.getVendorId());
            if (fb.getOrderId() > 0) ps.setInt(3, fb.getOrderId());
            else ps.setNull(3, Types.INTEGER);
            ps.setInt(4, fb.getRating());
            ps.setString(5, fb.getComments());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[FeedbackDAO.submitFeedback] " + e.getMessage());
        }
        return false;
    }

    /** Get all feedback for a vendor. */
    public List<Feedback> getFeedbackByVendor(int vendorId) {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT f.*, u.name AS customer_name " +
                     "FROM feedback f JOIN users u ON f.customer_id = u.id " +
                     "WHERE f.vendor_id = ? ORDER BY f.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vendorId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Feedback fb = mapRow(rs);
                fb.setCustomerName(rs.getString("customer_name"));
                list.add(fb);
            }

        } catch (SQLException e) {
            System.err.println("[FeedbackDAO.getFeedbackByVendor] " + e.getMessage());
        }
        return list;
    }

    /** Average rating for a vendor. */
    public double getAverageRating(int vendorId) {
        String sql = "SELECT COALESCE(AVG(rating),0) AS avg_rating FROM feedback WHERE vendor_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vendorId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble("avg_rating");

        } catch (SQLException e) {
            System.err.println("[FeedbackDAO.getAverageRating] " + e.getMessage());
        }
        return 0;
    }

    private Feedback mapRow(ResultSet rs) throws SQLException {
        Feedback fb = new Feedback();
        fb.setId(rs.getInt("id"));
        fb.setCustomerId(rs.getInt("customer_id"));
        fb.setVendorId(rs.getInt("vendor_id"));
        fb.setOrderId(rs.getInt("order_id"));
        fb.setRating(rs.getInt("rating"));
        fb.setComments(rs.getString("comments"));
        fb.setCreatedAt(rs.getString("created_at"));
        return fb;
    }
}
