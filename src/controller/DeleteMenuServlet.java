package controller;

import dao.MenuDAO;
import util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * DeleteMenuServlet – vendor deletes one of their menu items.
 * URL: /DeleteMenuServlet
 */
@WebServlet("/DeleteMenuServlet")
public class DeleteMenuServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.requireRole(request, response, "vendor")) return;

        int vendorId = SessionUtil.getUserId(request);
        int itemId   = 0;

        try { itemId = Integer.parseInt(request.getParameter("itemId")); }
        catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vendor/manageMenu.jsp?error=Invalid+item");
            return;
        }

        MenuDAO dao = new MenuDAO();
        boolean ok  = dao.deleteMenuItem(itemId, vendorId);

        response.sendRedirect(request.getContextPath() +
            "/vendor/manageMenu.jsp?" + (ok ? "success=Item+deleted" : "error=Delete+failed"));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
