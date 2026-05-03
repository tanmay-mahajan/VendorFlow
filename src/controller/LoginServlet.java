package controller;

import dao.UserDAO;
import model.User;
import util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * LoginServlet – handles GET (show form) and POST (authenticate).
 * URL: /LoginServlet
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    /** Show the login page. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // If already logged in, redirect to dashboard
        if (SessionUtil.isLoggedIn(request)) {
            redirectByRole(request, response);
            return;
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    /** Authenticate the user. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email")    != null ? request.getParameter("email").trim()    : "";
        String password = request.getParameter("password") != null ? request.getParameter("password").trim() : "";
        String role     = request.getParameter("role")     != null ? request.getParameter("role").trim()     : "customer";

        // Basic validation
        if (email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = userDAO.loginUser(email, password, role);

        if (user == null) {
            request.setAttribute("error", "Invalid email, password, or role. Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Create session
        HttpSession session = request.getSession(true);
        session.setAttribute(SessionUtil.SESSION_USER_ID,    user.getId());
        session.setAttribute(SessionUtil.SESSION_USER_NAME,  user.getName());
        session.setAttribute(SessionUtil.SESSION_USER_ROLE,  user.getRole());
        session.setAttribute(SessionUtil.SESSION_USER_EMAIL, user.getEmail());

        if ("vendor".equals(user.getRole())) {
            session.setAttribute(SessionUtil.SESSION_VENDOR_ID, user.getId());
        }

        // Redirect based on role
        redirectByRole(request, response);
    }

    private void redirectByRole(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String role = SessionUtil.getUserRole(req);
        String ctx  = req.getContextPath();
        if ("vendor".equals(role)) {
            resp.sendRedirect(ctx + "/vendor/dashboard.jsp");
        } else if ("admin".equals(role)) {
            resp.sendRedirect(ctx + "/admin/dashboard.jsp");
        } else {
            resp.sendRedirect(ctx + "/customer/dashboard.jsp");
        }
    }
}
