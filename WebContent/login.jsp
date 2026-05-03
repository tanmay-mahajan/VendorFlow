<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>

    <jsp:include page="/common/navbar.jsp" />

    <main class="d-flex align-items-center justify-content-center py-5">
        <div class="card shadow" style="width: 100%; max-width: 400px;">
            <div class="card-body p-4">
                <h3 class="card-title text-center mb-4 fw-bold">Welcome Back</h3>

                <% if(request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                <% } %>
                <% if(request.getAttribute("success") != null) { %>
                    <div class="alert alert-success"><%= request.getAttribute("success") %></div>
                <% } %>
                <% if(request.getParameter("success") != null) { %>
                    <div class="alert alert-success"><%= request.getParameter("success") %></div>
                <% } %>

                <form action="<%=request.getContextPath()%>/LoginServlet" method="post" class="needs-validation" novalidate>
                    <div class="mb-3">
                        <label class="form-label">Email address</label>
                        <input type="email" class="form-control" name="email" required placeholder="name@example.com">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Password</label>
                        <input type="password" class="form-control" name="password" required placeholder="********">
                    </div>
                    <div class="mb-4">
                        <label class="form-label">Login As</label>
                        <select class="form-select" name="role" required>
                            <option value="customer" selected>Customer</option>
                            <option value="vendor">Vendor</option>
                            <option value="admin">System Admin</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 py-2 fw-bold">Login</button>
                </form>

                <div class="text-center mt-4">
                    <span class="text-muted">Don't have an account? </span>
                    <a href="register.jsp" class="text-decoration-none">Register here</a>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/main.js"></script>
</body>
</html>

