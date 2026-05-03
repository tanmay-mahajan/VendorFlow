<%@ page import="dao.MenuDAO" %>
<%@ page import="model.MenuItem" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    MenuDAO dao = new MenuDAO();
    List<MenuItem> menu = dao.getAllAvailableMenuItems();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Browse Menu - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-4">
        <h2 class="fw-bold mb-4">Live Menu</h2>

        <% if(request.getParameter("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show">
                <%= request.getParameter("error") %>
            </div>
        <% } %>

        <div class="row row-cols-1 row-cols-md-3 g-4">
            <%
                String currentVendor = "";
                for (MenuItem item : menu) {
                    if (!item.getVendorShopName().equals(currentVendor)) {
                        currentVendor = item.getVendorShopName();
            %>
                        <div class="col-12 mt-4">
                            <h4 class="border-bottom pb-2 text-primary"><i class="bi bi-shop"></i> <%= currentVendor %></h4>
                        </div>
            <%      } %>
            
            <div class="col">
                <div class="card h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start">
                            <h5 class="card-title fw-bold"><%= item.getName() %></h5>
                            <span class="badge bg-success">₹<%= item.getPrice() %></span>
                        </div>
                        <p class="card-text text-muted small"><%= item.getDescription() %></p>
                        <p class="card-text mb-0"><small class="text-info"><%= item.getCategory() %></small></p>
                    </div>
                    <div class="card-footer bg-white border-top-0">
                        <form action="<%=request.getContextPath()%>/CartServlet" method="post" class="d-flex align-items-center">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="menuItemId" value="<%= item.getId() %>">
                            <input type="hidden" name="vendorId" value="<%= item.getVendorId() %>">
                            <input type="number" name="quantity" value="1" min="1" max="10" class="form-control form-control-sm me-2" style="width: 70px;">
                            <button type="submit" class="btn btn-outline-primary btn-sm w-100">Add to Cart</button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>
            
            <% if (menu.isEmpty()) { %>
                <div class="col-12">
                    <div class="alert alert-info">No menu items available right now. Please check back later.</div>
                </div>
            <% } %>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />
</body>
</html>

