package controller;

import dao.FeedbackDAO;
import model.Feedback;
import util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * FeedbackServlet – customer submits feedback/rating.
 * URL: /FeedbackServlet
 */
@WebServlet("/FeedbackServlet")
public class FeedbackServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.requireRole(request, response, "customer")) return;

        int    customerId = SessionUtil.getUserId(request);
        int    vendorId   = parseInt(request.getParameter("vendorId"),  0);
        int    orderId    = parseInt(request.getParameter("orderId"),   0);
        int    rating     = parseInt(request.getParameter("rating"),    0);
        String comments   = request.getParameter("comments");
        if (comments == null) comments = "";

        if (vendorId <= 0 || rating < 1 || rating > 5) {
            response.sendRedirect(request.getContextPath() +
                "/customer/history.jsp?error=Invalid+feedback+data");
            return;
        }

        Feedback fb = new Feedback();
        fb.setCustomerId(customerId);
        fb.setVendorId(vendorId);
        fb.setOrderId(orderId);
        fb.setRating(rating);
        fb.setComments(comments.trim());

        FeedbackDAO dao = new FeedbackDAO();
        boolean ok = dao.submitFeedback(fb);

        response.sendRedirect(request.getContextPath() +
            "/customer/history.jsp?" + (ok ? "success=Thank+you+for+your+feedback!" : "error=Feedback+failed"));
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}
