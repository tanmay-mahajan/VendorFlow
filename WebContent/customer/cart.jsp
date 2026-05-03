<%@ page import="controller.CartServlet" %>
<%@ page import="model.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    List<CartItem> cart = CartServlet.getCart(session);
    double total = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Cart - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-4">
        <h2 class="fw-bold mb-4">My Cart</h2>

        <% if(request.getParameter("error") != null) { %>
            <div class="alert alert-danger"><%= request.getParameter("error") %></div>
        <% } %>

        <% if (cart.isEmpty()) { %>
            <div class="text-center py-5">
                <i class="bi bi-cart-x display-1 text-muted mb-3"></i>
                <h4>Your cart is empty</h4>
                <p class="text-muted">Looks like you haven't added anything yet.</p>
                <a href="menu.jsp" class="btn btn-primary mt-3">Browse Menu</a>
            </div>
        <% } else { %>
            <div class="row">
                <div class="col-lg-8">
                    <div class="card shadow-sm mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">Ordering from: <span class="text-primary"><%= cart.get(0).getVendorShopName() %></span></h5>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 align-middle">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Item</th>
                                            <th>Price</th>
                                            <th style="width: 120px;">Qty</th>
                                            <th>Subtotal</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (CartItem ci : cart) { 
                                               total += ci.getSubtotal(); %>
                                        <tr>
                                            <td class="fw-bold"><%= ci.getMenuItemName() %></td>
                                            <td>â‚¹<%= ci.getUnitPrice() %></td>
                                            <td>
                                                <form action="<%=request.getContextPath()%>/CartServlet" method="post" class="d-flex">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="menuItemId" value="<%= ci.getMenuItemId() %>">
                                                    <input type="number" name="quantity" value="<%= ci.getQuantity() %>" min="1" max="20" class="form-control form-control-sm me-1">
                                                    <button type="submit" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-clockwise"></i></button>
                                                </form>
                                            </td>
                                            <td>â‚¹<%= ci.getSubtotal() %></td>
                                            <td>
                                                <form action="<%=request.getContextPath()%>/CartServlet" method="post">
                                                    <input type="hidden" name="action" value="remove">
                                                    <input type="hidden" name="menuItemId" value="<%= ci.getMenuItemId() %>">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
                                                </form>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="card-footer bg-white text-end">
                            <form action="<%=request.getContextPath()%>/CartServlet" method="post" class="d-inline">
                                <input type="hidden" name="action" value="clear">
                                <button type="submit" class="btn btn-link text-danger" onclick="return confirm('Clear entire cart?');">Clear Cart</button>
                            </form>
                        </div>
                    </div>
                </div>
                
                <div class="col-lg-4">
                    <div class="card shadow-sm">
                        <div class="card-body">
                            <h5 class="card-title fw-bold border-bottom pb-3 mb-3">Order Summary</h5>
                            <div class="d-flex justify-content-between mb-2">
                                <span>Subtotal</span>
                                <span>â‚¹<%= total %></span>
                            </div>
                            <div class="d-flex justify-content-between mb-3 text-success">
                                <span>Taxes & Fees</span>
                                <span>â‚¹0.00</span>
                            </div>
                            <div class="d-flex justify-content-between mb-4 border-top pt-3">
                                <h5 class="fw-bold">Total</h5>
                                <h5 class="fw-bold text-primary">â‚¹<%= total %></h5>
                            </div>

                            <form action="<%=request.getContextPath()%>/PlaceOrderServlet" method="post" id="placeOrderForm">
                                <div class="mb-3">
                                    <label class="form-label text-muted small">Special Instructions (optional)</label>
                                    <textarea name="specialNotes" class="form-control form-control-sm" rows="2" placeholder="E.g. less spicy, extra ketchup"></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary w-100 btn-lg fw-bold" onclick="this.disabled=true; this.form.submit();">Place Order</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>
    </main>

    <jsp:include page="/common/footer.jsp" />
</body>
</html>

