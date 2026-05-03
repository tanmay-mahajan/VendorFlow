<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-5 text-center">
        <h2 class="fw-bold mb-4">Admin Dashboard</h2>
        <div class="alert alert-info d-inline-block shadow-sm">
            <i class="bi bi-tools fs-4 text-primary d-block mb-2"></i>
            <h5 class="alert-heading">Under Construction</h5>
            <p class="mb-0">The admin module (managing vendors and customers) is optional and currently under development for a future release.</p>
        </div>
        <div class="mt-4">
            <a href="<%=request.getContextPath()%>/LogoutServlet" class="btn btn-outline-danger">Logout Admin</a>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />
</body>
</html>

