package controller;

import dao.OrderDAO;
import model.CartItem;
import model.Order;
import model.OrderItem;
import util.SessionUtil;
import util.TokenGenerator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * PlaceOrderServlet – converts cart into an order, generates token.
 * URL: /PlaceOrderServlet
 */
@WebServlet("/PlaceOrderServlet")
public class PlaceOrderServlet extends HttpServlet {

    private static final String CART_KEY = "cart";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.requireRole(request, response, "customer")) return;

        HttpSession    session = request.getSession(false);
        List<CartItem> cart    = getCart(session);

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?error=Cart+is+empty");
            return;
        }

        int    customerId   = SessionUtil.getUserId(request);
        int    vendorId     = cart.get(0).getVendorId();
        String specialNotes = request.getParameter("specialNotes");
        if (specialNotes == null) specialNotes = "";

        // Calculate total
        double total = 0;
        List<OrderItem> items = new ArrayList<>();
        for (CartItem ci : cart) {
            total += ci.getSubtotal();
            OrderItem oi = new OrderItem();
            oi.setMenuItemId(ci.getMenuItemId());
            oi.setQuantity(ci.getQuantity());
            oi.setUnitPrice(ci.getUnitPrice());
            items.add(oi);
        }

        // Generate token
        int token = TokenGenerator.getNextToken(vendorId);

        // Build Order
        Order order = new Order();
        order.setCustomerId(customerId);
        order.setVendorId(vendorId);
        order.setTokenNumber(token);
        order.setTotalAmount(total);
        order.setStatus("Pending");
        order.setSpecialNotes(specialNotes);
        order.setItems(items);

        OrderDAO orderDAO = new OrderDAO();
        int orderId = orderDAO.placeOrder(order);

        if (orderId < 0) {
            response.sendRedirect(request.getContextPath() + "/customer/cart.jsp?error=Order+failed.+Please+try+again");
            return;
        }

        // Clear cart from session
        session.removeAttribute(CART_KEY);

        // Redirect to token status page
        response.sendRedirect(request.getContextPath() +
            "/customer/tokenStatus.jsp?orderId=" + orderId + "&token=" + token);
    }

    @SuppressWarnings("unchecked")
    private List<CartItem> getCart(HttpSession session) {
        if (session == null) return null;
        Object obj = session.getAttribute(CART_KEY);
        return (obj instanceof List) ? (List<CartItem>) obj : null;
    }
}
