<%@ page import="dao.UserDAO" %>
<%@ page import="model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"vendor".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    int vendorId = (session != null && session.getAttribute("userId") != null ? (Integer) session.getAttribute("userId") : -1);
    
    UserDAO dao = new UserDAO();
    
    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String shopName = request.getParameter("shopName");
        String shopAddress = request.getParameter("shopAddress");
        
        User update = new User();
        update.setId(vendorId);
        update.setName(name);
        update.setPhone(phone);
        update.setShopName(shopName);
        update.setShopAddress(shopAddress);
        
        boolean ok = dao.updateProfile(update);
        if (ok) {
            session.setAttribute("userName", name);
            response.sendRedirect("profile.jsp?success=Profile updated successfully");
            return;
        } else {
            request.setAttribute("error", "Update failed.");
        }
    }
    
    User vendor = dao.getUserById(vendorId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Vendor Profile - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card shadow">
                    <div class="card-header bg-white pb-0">
                        <h4 class="fw-bold">Shop Profile</h4>
                    </div>
                    <div class="card-body">
                        <% if(request.getParameter("success") != null) { %>
                            <div class="alert alert-success"><%= request.getParameter("success") %></div>
                        <% } %>
                        <% if(request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                        <% } %>

                        <form method="post" action="profile.jsp">
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Full Name</label>
                                    <input type="text" name="name" class="form-control" value="<%= vendor.getName() %>" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Phone</label>
                                    <input type="text" name="phone" class="form-control" value="<%= vendor.getPhone() %>" required>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Email Address (Read Only)</label>
                                <input type="email" class="form-control bg-light" value="<%= vendor.getEmail() %>" readonly>
                            </div>

                            <hr class="my-4">
                            <h5 class="fw-bold mb-3">Shop Details</h5>

                            <div class="mb-3">
                                <label class="form-label">Shop / Stall Name</label>
                                <input type="text" name="shopName" class="form-control" value="<%= vendor.getShopName() %>" required>
                            </div>
                            
                            <div class="mb-4">
                                <label class="form-label">Shop Address / Location</label>
                                <textarea name="shopAddress" class="form-control" rows="3" required><%= vendor.getShopAddress() %></textarea>
                            </div>

                            <button type="submit" class="btn btn-primary d-block w-100">Save Changes</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />
</body>
</html>

