package controller;

import dao.UserDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * RegisterServlet – handles new user registration.
 * URL: /RegisterServlet
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name        = trim(request.getParameter("name"));
        String email       = trim(request.getParameter("email"));
        String password    = trim(request.getParameter("password"));
        String phone       = trim(request.getParameter("phone"));
        String role        = trim(request.getParameter("role"));
        String shopName    = trim(request.getParameter("shopName"));
        String shopAddress = trim(request.getParameter("shopAddress"));

        // Validate required fields
        if (name.isEmpty() || email.isEmpty() || password.isEmpty() || role.isEmpty()) {
            request.setAttribute("error", "Name, email, password and role are required.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!"customer".equals(role) && !"vendor".equals(role)) {
            request.setAttribute("error", "Invalid role selected.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();

        // Check duplicate email
        if (userDAO.emailExists(email)) {
            request.setAttribute("error", "This email is already registered. Please login.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Build user object
        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(password);  // Plain text (acceptable for college project)
        user.setPhone(phone);
        user.setRole(role);
        user.setShopName(shopName);
        user.setShopAddress(shopAddress);

        int newId = userDAO.registerUser(user);
        if (newId < 0) {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        request.setAttribute("success", "Registration successful! Please login.");
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    private String trim(String s) {
        return s != null ? s.trim() : "";
    }
}
