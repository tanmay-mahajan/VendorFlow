<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customer Dashboard - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-5">
        <h2 class="fw-bold mb-4">Welcome, <%= ((String) session.getAttribute("userName")) %>!</h2>

        <div class="row g-4">
            <!-- Browse Menu -->
            <div class="col-md-4">
                <div class="card dash-card h-100">
                    <div class="card-body text-center py-5">
                        <i class="bi bi-book display-4 text-primary mb-3"></i>
                        <h4 class="card-title">Browse Menu</h4>
                        <p class="text-muted">View live menus from all vendors and place your order.</p>
                        <a href="menu.jsp" class="btn btn-primary mt-2">Go to Menu</a>
                    </div>
                </div>
            </div>

            <!-- Cart -->
            <div class="col-md-4">
                <div class="card dash-card h-100" style="border-left-color: #ff9800;">
                    <div class="card-body text-center py-5">
                        <i class="bi bi-cart3 display-4 text-warning mb-3"></i>
                        <h4 class="card-title">My Cart</h4>
                        <p class="text-muted">Review your selected items and checkout.</p>
                        <a href="cart.jsp" class="btn btn-warning text-dark mt-2">View Cart</a>
                    </div>
                </div>
            </div>

            <!-- Order History -->
            <div class="col-md-4">
                <div class="card dash-card h-100" style="border-left-color: #4caf50;">
                    <div class="card-body text-center py-5">
                        <i class="bi bi-clock-history display-4 text-success mb-3"></i>
                        <h4 class="card-title">Order History & Status</h4>
                        <p class="text-muted">Track live token status and view past orders.</p>
                        <a href="history.jsp" class="btn btn-success mt-2">View History</a>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

