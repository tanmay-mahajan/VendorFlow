<%@ page import="java.util.List" %>
<%@ page import="model.Order" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"vendor".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    List<Order> queue = (List<Order>) request.getAttribute("queue");
    // If entered directly, redirect to Servlet to fetch data
    if (queue == null) {
        response.sendRedirect(request.getContextPath() + "/QueueServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Live Queue - VendorFlow</title>
    <!-- Auto refresh so vendor sees new orders immediately -->
    <meta http-equiv="refresh" content="15">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
            <h2 class="fw-bold mb-0 text-primary"><i class="bi bi-list-ol"></i> Live FCFS Queue</h2>
            <div class="text-muted small">Auto-updating every 15s</div>
        </div>

        <% if(request.getParameter("success") != null) { %>
            <div class="alert alert-success"><%= request.getParameter("success") %></div>
        <% } %>
        <% if(request.getParameter("error") != null) { %>
            <div class="alert alert-danger"><%= request.getParameter("error") %></div>
        <% } %>

        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            <% for (Order o : queue) { 
                boolean isReady = "Ready".equals(o.getStatus());
                boolean isPrep = "Preparing".equals(o.getStatus());
            %>
            <div class="col">
                <div class="card h-100 shadow-sm queue-card <%= isReady ? "ready" : "" %>">
                    <div class="card-header d-flex justify-content-between align-items-center bg-transparent">
                        <span class="fs-5 fw-bold text-dark">Token #<%= o.getTokenNumber() %></span>
                        <span class="badge bg-<%= o.getStatus().toLowerCase() %>"><%= o.getStatus() %></span>
                    </div>
                    <div class="card-body">
                        <h6 class="card-title text-muted mb-2"><i class="bi bi-person"></i> <%= o.getCustomerName() %></h6>
                        
                        <!-- Actions -->
                        <div class="d-flex flex-column gap-2 mt-4">
                            <% if("Pending".equals(o.getStatus())) { %>
                                <form action="<%=request.getContextPath()%>/OrderStatusServlet" method="post">
                                    <input type="hidden" name="orderId" value="<%= o.getId() %>">
                                    <input type="hidden" name="status" value="Preparing">
                                    <input type="hidden" name="from" value="queue">
                                    <button class="btn btn-primary w-100"><i class="bi bi-fire"></i> Start Preparing</button>
                                </form>
                            <% } else if(isPrep) { %>
                                <form action="<%=request.getContextPath()%>/OrderStatusServlet" method="post">
                                    <input type="hidden" name="orderId" value="<%= o.getId() %>">
                                    <input type="hidden" name="status" value="Ready">
                                    <input type="hidden" name="from" value="queue">
                                    <button class="btn btn-success w-100"><i class="bi bi-bell"></i> Mark as Ready</button>
                                </form>
                            <% } else if(isReady) { %>
                                <form action="<%=request.getContextPath()%>/OrderStatusServlet" method="post">
                                    <input type="hidden" name="orderId" value="<%= o.getId() %>">
                                    <input type="hidden" name="status" value="Completed">
                                    <input type="hidden" name="from" value="queue">
                                    <button class="btn btn-secondary w-100"><i class="bi bi-check-all"></i> Handed Over (Complete)</button>
                                </form>
                            <% } %>
                            
                            <a href="<%=request.getContextPath()%>/vendor/orders.jsp" class="btn btn-outline-secondary btn-sm mt-2">View details</a>
                        </div>
                    </div>
                    <div class="card-footer bg-transparent text-muted small">
                         Ord: <%= o.getCreatedAt().substring(11, 16) %> | Amt: â‚¹<%= o.getTotalAmount() %>
                         <% if(o.getSpecialNotes() != null && !o.getSpecialNotes().isEmpty()) { %>
                            <div class="mt-1 text-danger">Note: <%= o.getSpecialNotes() %></div>
                         <% } %>
                    </div>
                </div>
            </div>
            <% } %>
            
            <% if(queue.isEmpty()) { %>
                <div class="col-12 text-center py-5">
                    <i class="bi bi-emoji-smile display-1 text-muted"></i>
                    <h3 class="mt-3 text-muted">Queue is empty</h3>
                    <p>No active orders at the moment. Relax!</p>
                </div>
            <% } %>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />
</body>
</html>

