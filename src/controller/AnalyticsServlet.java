package controller;

import com.google.gson.Gson;
import dao.AnalyticsDAO;
import util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * AnalyticsServlet – serves analytics data as JSON for Chart.js.
 * URL: /AnalyticsServlet
 *
 * Returns JSON:
 * {
 *   totalOrders, totalRevenue, todayRevenue, pendingOrders,
 *   completedOrders, totalCustomers,
 *   ordersPerDay:  {Mon:2, Tue:5, ...},
 *   topItems:      {ItemA:12, ItemB:8, ...},
 *   peakHours:     {9AM:4, 10AM:7, ...}
 * }
 */
@WebServlet("/AnalyticsServlet")
public class AnalyticsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.requireRole(request, response, "vendor")) return;

        int          vendorId = SessionUtil.getUserId(request);
        AnalyticsDAO dao      = new AnalyticsDAO();

        Map<String, Object> data = new HashMap<>();
        data.put("totalOrders",     dao.getTotalOrders(vendorId));
        data.put("totalRevenue",    dao.getTotalRevenue(vendorId));
        data.put("todayRevenue",    dao.getTodayRevenue(vendorId));
        data.put("pendingOrders",   dao.getPendingOrders(vendorId));
        data.put("completedOrders", dao.getCompletedOrders(vendorId));
        data.put("totalCustomers",  dao.getTotalCustomers(vendorId));
        data.put("ordersPerDay",    dao.getOrdersPerDayOfWeek(vendorId));
        data.put("topItems",        dao.getTopItems(vendorId));
        data.put("peakHours",       dao.getPeakHours(vendorId));

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(data));
    }
}
