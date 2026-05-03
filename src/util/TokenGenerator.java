package util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * TokenGenerator – generates sequential daily token numbers per vendor.
 *
 * Logic:
 *   SELECT MAX(token_number) FROM orders
 *   WHERE vendor_id = ? AND DATE(created_at) = CURRENT_DATE
 *
 * Returns MAX + 1 (or 1 if no orders today).
 */
public class TokenGenerator {

    /**
     * Get next token number for a vendor (resets to 1 each day).
     *
     * @param vendorId  The vendor's user id
     * @return          Next token number (1-based)
     */
    public static int getNextToken(int vendorId) {
        String sql = "SELECT COALESCE(MAX(token_number), 0) + 1 AS next_token " +
                     "FROM orders " +
                     "WHERE vendor_id = ? AND DATE(created_at) = CURRENT_DATE";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vendorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("next_token");
                }
            }
        } catch (SQLException e) {
            System.err.println("[TokenGenerator] Error generating token: " + e.getMessage());
        }

        return 1; // fallback
    }
}
