<%@ page import="dao.OrderDAO" %>
<%@ page import="model.Order" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    
    int orderId = 0;
    try { orderId = Integer.parseInt(request.getParameter("orderId")); } 
    catch(Exception e) {}
    
    OrderDAO dao = new OrderDAO();
    Order order = dao.getTokenStatus((session != null && session.getAttribute("userId") != null ? (Integer) session.getAttribute("userId") : -1), orderId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Token Status - VendorFlow</title>
    <% if(order != null && !"Completed".equals(order.getStatus())) { %>
    <!-- Auto refresh every 10 seconds to check status -->
    <meta http-equiv="refresh" content="10">
    <% } %>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
    <style>
        .token-circle {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto;
            border: 8px solid;
            font-size: 4rem;
            font-weight: bold;
        }
        .status-Preparing .token-circle { border-color: #2196f3; color: #2196f3; }
        .status-Ready .token-circle { border-color: #4caf50; color: #4caf50; }
        .status-Pending .token-circle { border-color: #ff9800; color: #ff9800; }
        .status-Completed .token-circle { border-color: #9e9e9e; color: #9e9e9e; }
    </style>
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-5 text-center">
        <% if (order == null) { %>
            <div class="alert alert-danger">Order not found.</div>
            <a href="history.jsp" class="btn btn-primary">Go to History</a>
        <% } else { %>
            <div class="card shadow mx-auto" style="max-width: 500px;">
                <div class="card-header bg-white py-3">
                    <h4 class="mb-0">Order Placed Successfully!</h4>
                </div>
                <div class="card-body py-5 status-<%= order.getStatus() %>">
                    <p class="text-muted mb-4">Your token number for <strong><%= order.getVendorShopName() %></strong> is</p>
                    
                    <div class="token-circle mb-4">
                        <%= order.getTokenNumber() %>
                    </div>
                    
                    <h2 class="fw-bold mb-2"><%= order.getStatus() %></h2>
                    
                    <% if("Pending".equals(order.getStatus())) { %>
                        <p class="text-muted">Waiting for vendor to start preparation.</p>
                    <% } else if("Preparing".equals(order.getStatus())) { %>
                        <p class="text-primary">Your food is being prepared! Please wait near the stall.</p>
                    <% } else if("Ready".equals(order.getStatus())) { %>
                        <p class="text-success fw-bold fs-5"><i class="bi bi-bell-fill"></i> Your order is ready for pickup!</p>
                    <% } else if("Completed".equals(order.getStatus())) { %>
                        <p class="text-muted">Order completed. Enjoy your meal!</p>
                        <a href="history.jsp" class="btn btn-outline-primary mt-3">Leave Feedback</a>
                    <% } %>
                    
                    <div class="mt-5 pt-3 border-top">
                        <small class="text-muted">Page auto-refreshes every 10 seconds. <a href="javascript:location.reload();">Refresh now</a></small>
                    </div>
                </div>
            </div>
        <% } %>
    </main>

    <jsp:include page="/common/footer.jsp" />
</body>
</html>

