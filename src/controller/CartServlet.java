package controller;

import com.google.gson.Gson;
import dao.MenuDAO;
import model.CartItem;
import model.MenuItem;
import util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * CartServlet – manage the session-based shopping cart.
 *
 * Actions (POST param "action"):
 *   add    – add/increment item
 *   remove – remove item
 *   update – change qty
 *   clear  – empty cart
 *
 * URL: /CartServlet
 */
@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {

    private static final String CART_SESSION_KEY = "cart";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.requireRole(request, response, "customer")) return;

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "add":    handleAdd(request, response);    break;
            case "remove": handleRemove(request, response); break;
            case "update": handleUpdate(request, response); break;
            case "clear":  handleClear(request, response);  break;
            default:
                response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
    }

    // ─── Add item to cart ─────────────────────────────────────────────────────
    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int itemId    = parseInt(request.getParameter("menuItemId"),  0);
        int quantity  = parseInt(request.getParameter("quantity"),    1);
        int vendorId  = parseInt(request.getParameter("vendorId"),    0);

        if (itemId <= 0 || vendorId <= 0) {
            response.sendRedirect(request.getContextPath() + "/customer/menu.jsp?error=Invalid+item");
            return;
        }

        // Fetch item details from DB
        MenuDAO  menuDAO = new MenuDAO();
        MenuItem item    = menuDAO.getMenuItemById(itemId);
        if (item == null || !item.isAvailable()) {
            response.sendRedirect(request.getContextPath() + "/customer/menu.jsp?error=Item+not+available");
            return;
        }

        HttpSession     session = request.getSession(true);
        List<CartItem>  cart    = getCart(session);

        // Check if cart has items from a different vendor — block mixing
        if (!cart.isEmpty() && cart.get(0).getVendorId() != vendorId) {
            response.sendRedirect(request.getContextPath() +
                "/customer/menu.jsp?error=Please+clear+cart+before+ordering+from+a+different+vendor");
            return;
        }

        // Check if item already in cart → increase quantity
        boolean found = false;
        for (CartItem ci : cart) {
            if (ci.getMenuItemId() == itemId) {
                ci.setQuantity(ci.getQuantity() + quantity);
                found = true;
                break;
            }
        }

        if (!found) {
            // Vendor name (join already in getAllAvailableMenuItems; use simple DB call here)
            CartItem ci = new CartItem(itemId, item.getName(), item.getPrice(),
                                       quantity, vendorId, item.getVendorShopName() != null ? item.getVendorShopName() : "");
            cart.add(ci);
        }

        session.setAttribute(CART_SESSION_KEY, cart);
        response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
    }

    // ─── Remove item from cart ────────────────────────────────────────────────
    private void handleRemove(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int itemId = parseInt(request.getParameter("menuItemId"), 0);
        HttpSession    session = request.getSession(true);
        List<CartItem> cart    = getCart(session);
        cart.removeIf(ci -> ci.getMenuItemId() == itemId);
        session.setAttribute(CART_SESSION_KEY, cart);
        response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
    }

    // ─── Update item quantity ─────────────────────────────────────────────────
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int itemId   = parseInt(request.getParameter("menuItemId"), 0);
        int quantity = parseInt(request.getParameter("quantity"),   1);

        HttpSession    session = request.getSession(true);
        List<CartItem> cart    = getCart(session);

        for (CartItem ci : cart) {
            if (ci.getMenuItemId() == itemId) {
                if (quantity <= 0) cart.remove(ci);
                else ci.setQuantity(quantity);
                break;
            }
        }

        session.setAttribute(CART_SESSION_KEY, cart);
        response.sendRedirect(request.getContextPath() + "/customer/cart.jsp");
    }

    // ─── Clear entire cart ────────────────────────────────────────────────────
    private void handleClear(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        request.getSession(true).removeAttribute(CART_SESSION_KEY);
        response.sendRedirect(request.getContextPath() + "/customer/menu.jsp");
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    @SuppressWarnings("unchecked")
    public static List<CartItem> getCart(HttpSession session) {
        Object obj = session.getAttribute(CART_SESSION_KEY);
        if (obj instanceof List) return (List<CartItem>) obj;
        List<CartItem> cart = new ArrayList<>();
        session.setAttribute(CART_SESSION_KEY, cart);
        return cart;
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}
