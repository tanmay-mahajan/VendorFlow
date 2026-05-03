<%@ page import="dao.OrderDAO" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"vendor".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    int vendorId = (session != null && session.getAttribute("userId") != null ? (Integer) session.getAttribute("userId") : -1);
    OrderDAO dao = new OrderDAO();
    List<Order> orders = dao.getAllOrdersForVendor(vendorId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>All Orders - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-4">
        <h2 class="fw-bold mb-4">All Orders</h2>

        <% if(request.getParameter("success") != null) { %>
            <div class="alert alert-success alert-dismissible"><%= request.getParameter("success") %></div>
        <% } %>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Order ID</th>
                                <th>Date/Time</th>
                                <th>Customer</th>
                                <th>Token</th>
                                <th>Amount</th>
                                <th>Notes</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(Order o : orders) { %>
                                <tr>
                                    <td>#<%= o.getId() %></td>
                                    <td><%= o.getCreatedAt().substring(0, 16) %></td>
                                    <td><%= o.getCustomerName() %></td>
                                    <td><span class="fs-5 fw-bold"><%= o.getTokenNumber() %></span></td>
                                    <td>₹<%= o.getTotalAmount() %></td>
                                    <td class="text-danger small"><%= o.getSpecialNotes() != null ? o.getSpecialNotes() : "" %></td>
                                    <td>
                                        <span class="badge bg-<%= o.getStatus().toLowerCase() %>"><%= o.getStatus() %></span>
                                    </td>
                                    <td>
                                        <% if (!"Completed".equals(o.getStatus()) && !"Cancelled".equals(o.getStatus())) { %>
                                            <form action="<%=request.getContextPath()%>/OrderStatusServlet" method="post" class="d-inline">
                                                <input type="hidden" name="orderId" value="<%= o.getId() %>">
                                                <input type="hidden" name="from" value="orders">
                                                <select name="status" class="form-select form-select-sm d-inline-block w-auto" onchange="this.form.submit()">
                                                    <option value="Pending" <%= "Pending".equals(o.getStatus())?"selected":"" %>>Pending</option>
                                                    <option value="Preparing" <%= "Preparing".equals(o.getStatus())?"selected":"" %>>Preparing</option>
                                                    <option value="Ready" <%= "Ready".equals(o.getStatus())?"selected":"" %>>Ready</option>
                                                    <option value="Completed" <%= "Completed".equals(o.getStatus())?"selected":"" %>>Completed</option>
                                                    <option value="Cancelled" <%= "Cancelled".equals(o.getStatus())?"selected":"" %>>Cancelled</option>
                                                </select>
                                            </form>
                                        <% } else { %>
                                            <span class="text-muted"><i class="bi bi-lock"></i> Locked</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                            <% if(orders.isEmpty()) { %>
                                <tr><td colspan="8" class="text-center py-4">No orders received yet.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />
</body>
</html>

