<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/style.css?v=20260506-1" rel="stylesheet">
</head>
<body>

    <jsp:include page="/common/navbar.jsp" />

    <main class="d-flex align-items-center justify-content-center py-5">
        <div class="card shadow" style="width: 100%; max-width: 500px;">
            <div class="card-body p-4">
                <h3 class="card-title text-center mb-4 fw-bold">Create an Account</h3>

                <% if(request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                <% } %>

                <form action="<%=request.getContextPath()%>/RegisterServlet" method="post" class="needs-validation register-form" novalidate>
                    
                    <div class="mb-3">
                        <label class="form-label" for="nameInput">Full Name</label>
                        <input
                            type="text"
                            class="form-control"
                            name="name"
                            id="nameInput"
                            required
                            minlength="3"
                            pattern="[A-Za-z ]{3,}"
                            placeholder="Only alphabets"
                            oninput="validateName(this)">
                        <div class="invalid-feedback">Name must contain only alphabets and spaces, minimum 3 characters.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="emailInput">Email address</label>
                        <input
                            type="email"
                            class="form-control"
                            name="email"
                            id="emailInput"
                            required
                            placeholder="Valid email"
                            oninput="validateEmail(this)">
                        <div class="invalid-feedback">Please enter a valid email address.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="phoneInput">Phone Number</label>
                        <input
                            type="text"
                            class="form-control"
                            name="phone"
                            id="phoneInput"
                            required
                            pattern="[0-9]{10}"
                            inputmode="numeric"
                            maxlength="10"
                            placeholder="10-digit number only"
                            oninput="validatePhone(this)">
                        <div class="invalid-feedback">Phone must contain exactly 10 digits and numbers only.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="passwordInput">Password</label>
                        <input
                            type="password"
                            class="form-control"
                            name="password"
                            id="passwordInput"
                            required
                            minlength="6"
                            placeholder="Minimum 6 characters"
                            oninput="validatePassword(this)">
                        <div class="invalid-feedback">Password must be at least 6 characters.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="roleSelect">Register As</label>
                        <select class="form-select" name="role" id="roleSelect" onchange="toggleVendorFields()" required>
                            <option value="customer" selected>Customer</option>
                            <option value="vendor">Vendor</option>
                        </select>
                    </div>

                    <div id="vendorFields" style="display: none;" class="p-3 bg-light rounded mb-3 border">
                        <h6 class="mb-3 fw-bold text-primary">Vendor Details</h6>
                        <div class="mb-2">
                            <label class="form-label" for="shopName">Shop / Stall Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="shopName" id="shopName">
                        </div>
                        <div class="mb-2">
                            <label class="form-label" for="shopAddress">Shop Location / Address</label>
                            <textarea class="form-control" name="shopAddress" id="shopAddress" rows="2"></textarea>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 py-2 fw-bold mt-2">Register</button>
                </form>

                <div class="text-center mt-4">
                    <span class="text-muted">Already have an account? </span>
                    <a href="login.jsp" class="text-decoration-none">Login here</a>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/validation.js?v=20260506-1"></script>
    <script src="<%=request.getContextPath()%>/js/main.js?v=20260506-1"></script>
</body>
</html>
