package controller;

import dao.OrderDAO;
import util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * OrderStatusServlet – vendor changes order status (Pending → Preparing → Ready → Completed).
 * URL: /OrderStatusServlet
 */
@WebServlet("/OrderStatusServlet")
public class OrderStatusServlet extends HttpServlet {

    private static final java.util.Set<String> VALID_STATUSES = new java.util.HashSet<>(
        java.util.Arrays.asList("Pending","Preparing","Ready","Completed","Cancelled")
    );

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.requireRole(request, response, "vendor")) return;

        int    orderId = parseInt(request.getParameter("orderId"), 0);
        String status  = request.getParameter("status");
        String from    = request.getParameter("from"); // "queue" or "orders"

        if (orderId <= 0 || status == null || !VALID_STATUSES.contains(status)) {
            response.sendRedirect(request.getContextPath() + "/QueueServlet?error=Invalid+request");
            return;
        }

        OrderDAO dao = new OrderDAO();
        boolean  ok  = dao.updateOrderStatus(orderId, status);

        String redirectPage = "orders".equals(from) ? "/vendor/orders.jsp" : "/QueueServlet";

        response.sendRedirect(request.getContextPath() + redirectPage +
            "?" + (ok ? "success=Status+updated" : "error=Update+failed"));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}
