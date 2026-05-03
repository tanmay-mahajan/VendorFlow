<%@ page import="dao.AnalyticsDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"vendor".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    int vendorId = (session != null && session.getAttribute("userId") != null ? (Integer) session.getAttribute("userId") : -1);
    AnalyticsDAO dao = new AnalyticsDAO();
    int pending = dao.getPendingOrders(vendorId);
    double todayRev = dao.getTodayRevenue(vendorId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Vendor Dashboard - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-5">
        <h2 class="fw-bold mb-4">Vendor Dashboard</h2>

        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="card text-white bg-primary h-100 dash-card" style="border-left-color: #0d47a1;">
                    <div class="card-body">
                        <h5 class="card-title"><i class="bi bi-hourglass-split"></i> Pending Orders Today</h5>
                        <h1 class="display-3 fw-bold"><%= pending %></h1>
                        <a href="<%=request.getContextPath()%>/QueueServlet" class="text-white text-decoration-none mt-2 d-inline-block">Go to Live Queue &rarr;</a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card text-white bg-success h-100 dash-card" style="border-left-color: #1b5e20;">
                    <div class="card-body">
                        <h5 class="card-title"><i class="bi bi-currency-rupee"></i> Today's Revenue</h5>
                        <h1 class="display-3 fw-bold">â‚¹<%= todayRev %></h1>
                        <a href="analytics.jsp" class="text-white text-decoration-none mt-2 d-inline-block">View full analytics &rarr;</a>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 dash-card">
                    <div class="card-body text-center py-4">
                        <i class="bi bi-list-ul display-5 text-secondary mb-3"></i>
                        <h5>Manage Menu</h5>
                        <a href="manageMenu.jsp" class="btn btn-outline-secondary mt-2 w-100">Add / Edit Items</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 dash-card" style="border-left-color: #9c27b0;">
                    <div class="card-body text-center py-4">
                        <i class="bi bi-receipt display-5 text-purple mb-3" style="color: #9c27b0;"></i>
                        <h5>All past orders</h5>
                        <a href="orders.jsp" class="btn mt-2 w-100" style="background-color: #9c27b0; color: white;">View History</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 dash-card" style="border-left-color: #ff9800;">
                    <div class="card-body text-center py-4">
                        <i class="bi bi-shop display-5 text-warning mb-3"></i>
                        <h5>Shop Profile</h5>
                        <a href="profile.jsp" class="btn btn-outline-warning text-dark mt-2 w-100">Edit Details</a>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />
</body>
</html>

