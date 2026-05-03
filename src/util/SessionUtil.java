package util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * SessionUtil – helpers for session management.
 */
public class SessionUtil {

    // Session attribute key constants
    public static final String SESSION_USER_ID    = "userId";
    public static final String SESSION_USER_NAME  = "userName";
    public static final String SESSION_USER_ROLE  = "userRole";
    public static final String SESSION_USER_EMAIL = "userEmail";
    public static final String SESSION_VENDOR_ID  = "vendorId";

    /** Check if the user is logged in (has an active session). */
    public static boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute(SESSION_USER_ID) != null;
    }

    /** Get the user ID from session. Returns -1 if not logged in. */
    public static int getUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return -1;
        Object id = session.getAttribute(SESSION_USER_ID);
        return id != null ? (Integer) id : -1;
    }

    /** Get the user role from session ("customer", "vendor", "admin"). */
    public static String getUserRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (String) session.getAttribute(SESSION_USER_ROLE);
    }

    /** Get the user name from session. */
    public static String getUserName(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (String) session.getAttribute(SESSION_USER_NAME);
    }

    /**
     * Redirect if user is NOT logged in or doesn't have required role.
     * @return true  if the user passed the guard (continue processing)
     *         false if redirect was sent (stop processing in servlet)
     */
    public static boolean requireRole(HttpServletRequest req,
                                      HttpServletResponse resp,
                                      String requiredRole) throws IOException {
        if (!isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return false;
        }
        String role = getUserRole(req);
        if (requiredRole != null && !requiredRole.equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    /** Invalidate session and redirect to login page. */
    public static void logout(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) session.invalidate();
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }
}
