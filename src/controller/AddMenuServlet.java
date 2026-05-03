package controller;

import dao.MenuDAO;
import model.MenuItem;
import util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * AddMenuServlet – vendor adds a new menu item.
 * URL: /AddMenuServlet
 */
@WebServlet("/AddMenuServlet")
public class AddMenuServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.requireRole(request, response, "vendor")) return;

        int    vendorId    = SessionUtil.getUserId(request);
        String name        = trim(request.getParameter("name"));
        String description = trim(request.getParameter("description"));
        String priceStr    = trim(request.getParameter("price"));
        String category    = trim(request.getParameter("category"));
        String available   = request.getParameter("isAvailable");

        if (name.isEmpty() || priceStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/vendor/manageMenu.jsp?error=Name+and+price+are+required");
            return;
        }

        double price = 0;
        try { price = Double.parseDouble(priceStr); }
        catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vendor/manageMenu.jsp?error=Invalid+price");
            return;
        }

        MenuItem item = new MenuItem();
        item.setVendorId(vendorId);
        item.setName(name);
        item.setDescription(description);
        item.setPrice(price);
        item.setCategory(category.isEmpty() ? "General" : category);
        item.setAvailable(!"false".equals(available));

        MenuDAO dao = new MenuDAO();
        int newId = dao.addMenuItem(item);

        if (newId > 0) {
            response.sendRedirect(request.getContextPath() + "/vendor/manageMenu.jsp?success=Item+added");
        } else {
            response.sendRedirect(request.getContextPath() + "/vendor/manageMenu.jsp?error=Failed+to+add+item");
        }
    }

    private String trim(String s) { return s != null ? s.trim() : ""; }
}
