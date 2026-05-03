<%
    boolean isLoggedIn = session != null && session.getAttribute("userId") != null;
    String userRole = session != null ? (String) session.getAttribute("userRole") : null;
    String userName = session != null ? (String) session.getAttribute("userName") : null;
%>
<nav class="navbar navbar-expand-lg navbar-light bg-white sticky-top">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center" href="<%=request.getContextPath()%>/index.jsp">
            <i class="bi bi-shop fs-4 me-2 text-primary"></i> VendorFlow
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <% if (!isLoggedIn) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="<%=request.getContextPath()%>/index.jsp">Home</a>
                    </li>
                    <li class="nav-item ms-2">
                        <a class="btn btn-outline-primary btn-sm" href="<%=request.getContextPath()%>/login.jsp">Login</a>
                    </li>
                    <li class="nav-item ms-2">
                        <a class="btn btn-primary btn-sm" href="<%=request.getContextPath()%>/register.jsp">Register</a>
                    </li>
                <% } else { %>
                    <li class="nav-item">
                        <span class="nav-link text-muted">Hi, <%= userName %></span>
                    </li>

                    <% if ("customer".equals(userRole)) { %>
                        <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/customer/dashboard.jsp">Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/customer/menu.jsp">Browse Menu</a></li>
                        <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/customer/cart.jsp"><i class="bi bi-cart3"></i> Cart</a></li>
                        <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/customer/history.jsp">History</a></li>
                    <% } else if ("vendor".equals(userRole)) { %>
                        <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/vendor/dashboard.jsp">Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/vendor/manageMenu.jsp">Menu</a></li>
                        <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/QueueServlet">Queue</a></li>
                        <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/vendor/orders.jsp">Orders</a></li>
                        <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/vendor/analytics.jsp">Analytics</a></li>
                    <% } else if ("admin".equals(userRole)) { %>
                        <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/admin/dashboard.jsp">Dashboard</a></li>
                    <% } %>

                    <li class="nav-item ms-3">
                        <a class="btn btn-outline-danger btn-sm" href="<%=request.getContextPath()%>/LogoutServlet">Logout</a>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

