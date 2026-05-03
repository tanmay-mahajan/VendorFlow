<%@ page import="dao.MenuDAO" %>
<%@ page import="model.MenuItem" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"vendor".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    int vendorId = (session != null && session.getAttribute("userId") != null ? (Integer) session.getAttribute("userId") : -1);
    MenuDAO dao = new MenuDAO();
    List<MenuItem> menu = dao.getMenuByVendor(vendorId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Menu - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold mb-0">Manage Menu</h2>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addMenuModal">
                <i class="bi bi-plus-lg"></i> Add New Item
            </button>
        </div>

        <% if(request.getParameter("success") != null) { %>
            <div class="alert alert-success"><%= request.getParameter("success") %></div>
        <% } %>
        <% if(request.getParameter("error") != null) { %>
            <div class="alert alert-danger"><%= request.getParameter("error") %></div>
        <% } %>

        <div class="card shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Item Name</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Status</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(MenuItem item : menu) { %>
                                <tr>
                                    <td>
                                        <strong><%= item.getName() %></strong>
                                        <div class="small text-muted"><%= item.getDescription() %></div>
                                    </td>
                                    <td><%= item.getCategory() %></td>
                                    <td class="fw-bold">â‚¹<%= item.getPrice() %></td>
                                    <td>
                                        <% if(item.isAvailable()) { %>
                                            <span class="badge bg-success">Available</span>
                                        <% } else { %>
                                            <span class="badge bg-danger">Out of Stock</span>
                                        <% } %>
                                    </td>
                                    <td class="text-end">
                                        <button class="btn btn-sm btn-outline-secondary me-1" 
                                                data-bs-toggle="modal" data-bs-target="#editMenuModal<%= item.getId() %>">
                                            <i class="bi bi-pencil"></i> Edit
                                        </button>
                                        <form action="<%=request.getContextPath()%>/DeleteMenuServlet" method="post" class="d-inline">
                                            <input type="hidden" name="itemId" value="<%= item.getId() %>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this item?');">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>

                                <!-- Edit Modal for this item -->
                                <div class="modal fade" id="editMenuModal<%= item.getId() %>" tabindex="-1">
                                    <div class="modal-dialog">
                                        <form action="<%=request.getContextPath()%>/UpdateMenuServlet" method="post" class="modal-content">
                                            <input type="hidden" name="itemId" value="<%= item.getId() %>">
                                            <div class="modal-header">
                                                <h5 class="modal-title">Edit Item</h5>
                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                            </div>
                                            <div class="modal-body">
                                                <div class="mb-3">
                                                    <label class="form-label">Item Name</label>
                                                    <input type="text" name="name" class="form-control" value="<%= item.getName() %>" required>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label">Description</label>
                                                    <textarea name="description" class="form-control" rows="2"><%= item.getDescription() %></textarea>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-6">
                                                        <label class="form-label">Price (â‚¹)</label>
                                                        <input type="number" step="0.01" name="price" class="form-control" value="<%= item.getPrice() %>" required>
                                                    </div>
                                                    <div class="col-6">
                                                        <label class="form-label">Category</label>
                                                        <input type="text" name="category" class="form-control" value="<%= item.getCategory() %>">
                                                    </div>
                                                </div>
                                                <div class="form-check form-switch mb-3">
                                                    <input class="form-check-input" type="checkbox" name="isAvailable" value="true" <%= item.isAvailable() ? "checked" : "" %>>
                                                    <label class="form-check-label">Available (In Stock)</label>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                                <button type="submit" class="btn btn-primary">Save Changes</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            <% } %>
                            <% if(menu.isEmpty()) { %>
                                <tr><td colspan="5" class="text-center py-4">No menu items added yet. Click 'Add New Item' to begin.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <!-- Add Menu Modal -->
    <div class="modal fade" id="addMenuModal" tabindex="-1">
        <div class="modal-dialog">
            <form action="<%=request.getContextPath()%>/AddMenuServlet" method="post" class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add New Menu Item</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Item Name</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <textarea name="description" class="form-control" rows="2"></textarea>
                    </div>
                    <div class="row mb-3">
                        <div class="col-6">
                            <label class="form-label">Price (â‚¹)</label>
                            <input type="number" step="0.01" name="price" class="form-control" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Category</label>
                            <input type="text" name="category" class="form-control" placeholder="E.g. Snacks">
                        </div>
                    </div>
                    <div class="form-check form-switch mb-3">
                        <input class="form-check-input" type="checkbox" name="isAvailable" value="true" checked>
                        <label class="form-check-label">Available</label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary">Add Item</button>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="/common/footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

