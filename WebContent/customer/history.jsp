<%@ page import="dao.OrderDAO" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    int customerId = (session != null && session.getAttribute("userId") != null ? (Integer) session.getAttribute("userId") : -1);
    OrderDAO dao = new OrderDAO();
    List<Order> orders = dao.getOrdersByCustomer(customerId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order History - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-4">
        <h2 class="fw-bold mb-4">Order History</h2>

        <% if(request.getParameter("success") != null) { %>
            <div class="alert alert-success alert-dismissible"><%= request.getParameter("success") %></div>
        <% } %>
        <% if(request.getParameter("error") != null) { %>
            <div class="alert alert-danger alert-dismissible"><%= request.getParameter("error") %></div>
        <% } %>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0 align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Order ID</th>
                                <th>Date/Time</th>
                                <th>Vendor</th>
                                <th>Token</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(Order o : orders) { %>
                                <tr>
                                    <td>#<%= o.getId() %></td>
                                    <td><%= o.getCreatedAt().substring(0, 16) %></td>
                                    <td><%= o.getVendorShopName() %></td>
                                    <td><strong class="fs-5"><%= o.getTokenNumber() %></strong></td>
                                    <td>â‚¹<%= o.getTotalAmount() %></td>
                                    <td>
                                        <span class="badge bg-<%= o.getStatus().toLowerCase() %>"><%= o.getStatus() %></span>
                                    </td>
                                    <td>
                                        <% if ("Completed".equals(o.getStatus())) { %>
                                            <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#feedbackModal<%= o.getId() %>">
                                                Rate
                                            </button>
                                        <% } else if(!"Cancelled".equals(o.getStatus())) { %>
                                            <a href="tokenStatus.jsp?orderId=<%= o.getId() %>" class="btn btn-sm btn-info text-white">Track</a>
                                        <% } %>
                                    </td>
                                </tr>

                                <!-- Feedback Modal -->
                                <div class="modal fade" id="feedbackModal<%= o.getId() %>" tabindex="-1">
                                    <div class="modal-dialog">
                                        <div class="modal-content">
                                            <form action="<%=request.getContextPath()%>/FeedbackServlet" method="post">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">Rate Order #<%= o.getId() %></h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <input type="hidden" name="orderId" value="<%= o.getId() %>">
                                                    <input type="hidden" name="vendorId" value="<%= o.getVendorId() %>">
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label">Rating</label>
                                                        <select name="rating" class="form-select" required>
                                                            <option value="5">5 - Excellent</option>
                                                            <option value="4">4 - Good</option>
                                                            <option value="3">3 - Average</option>
                                                            <option value="2">2 - Poor</option>
                                                            <option value="1">1 - Terrible</option>
                                                        </select>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label">Comments (Optional)</label>
                                                        <textarea name="comments" class="form-control" rows="2"></textarea>
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="submit" class="btn btn-primary">Submit Feedback</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                            <% if(orders.isEmpty()) { %>
                                <tr><td colspan="7" class="text-center py-4">No past orders found.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

