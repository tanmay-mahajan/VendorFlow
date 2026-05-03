package controller;

import dao.MenuDAO;
import model.MenuItem;
import util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * UpdateMenuServlet – vendor edits an existing menu item.
 * URL: /UpdateMenuServlet
 */
@WebServlet("/UpdateMenuServlet")
public class UpdateMenuServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.requireRole(request, response, "vendor")) return;

        int vendorId = SessionUtil.getUserId(request);

        int itemId = 0;
        try { itemId = Integer.parseInt(request.getParameter("itemId")); }
        catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vendor/manageMenu.jsp?error=Invalid+item");
            return;
        }

        String name        = trim(request.getParameter("name"));
        String description = trim(request.getParameter("description"));
        String priceStr    = trim(request.getParameter("price"));
        String category    = trim(request.getParameter("category"));
        String available   = request.getParameter("isAvailable");

        double price = 0;
        try { price = Double.parseDouble(priceStr); }
        catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vendor/manageMenu.jsp?error=Invalid+price");
            return;
        }

        MenuItem item = new MenuItem();
        item.setId(itemId);
        item.setVendorId(vendorId);
        item.setName(name);
        item.setDescription(description);
        item.setPrice(price);
        item.setCategory(category.isEmpty() ? "General" : category);
        item.setAvailable("true".equals(available));

        MenuDAO dao = new MenuDAO();
        boolean ok = dao.updateMenuItem(item);

        response.sendRedirect(request.getContextPath() +
            "/vendor/manageMenu.jsp?" + (ok ? "success=Item+updated" : "error=Update+failed"));
    }

    private String trim(String s) { return s != null ? s.trim() : ""; }
}
