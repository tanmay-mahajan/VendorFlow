package controller;

import dao.OrderDAO;
import model.Order;
import util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * QueueServlet – loads the FCFS vendor queue and forwards to queue.jsp.
 * URL: /QueueServlet
 */
@WebServlet("/QueueServlet")
public class QueueServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.requireRole(request, response, "vendor")) return;

        int       vendorId = SessionUtil.getUserId(request);
        OrderDAO  dao      = new OrderDAO();
        List<Order> queue  = dao.getVendorQueue(vendorId);

        request.setAttribute("queue", queue);
        request.getRequestDispatcher("/vendor/queue.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
