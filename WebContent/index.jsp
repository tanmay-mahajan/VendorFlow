<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VendorFlow - Smart Queue & Order Management</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <!-- Custom CSS -->
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
    <style>
        .hero-section {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            padding: 72px 0;
            text-align: center;
        }
        .sdg-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.55rem;
            padding: 0.5rem 0.9rem;
            border: 1px solid rgba(12, 36, 97, 0.12);
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.76);
            box-shadow: 0 8px 18px rgba(12, 36, 97, 0.08);
            color: #1f2a37;
            font-weight: 700;
            line-height: 1.25;
            margin-bottom: 1.25rem;
        }
        .sdg-badge-number {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 62px;
            height: 30px;
            padding: 0 0.7rem;
            border-radius: 999px;
            background: var(--primary-color);
            color: #fff;
            font-size: 0.72rem;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }
        .sdg-badge-text {
            text-align: left;
            font-size: 0.84rem;
            color: #526071;
        }
        .feature-icon {
            font-size: 3rem;
            color: var(--primary-color);
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

    <jsp:include page="/common/navbar.jsp" />

    <main>
        <!-- Hero Section -->
        <section class="hero-section">
            <div class="container">
                <div class="sdg-badge" aria-label="Supports SDG 9 and SDG 11">
                    <span class="sdg-badge-number">SDG 9 + 11</span>
                    <span class="sdg-badge-text">Industry, Innovation and Infrastructure with Sustainable Cities and Communities</span>
                </div>
                <h1 class="display-4 fw-bold text-dark mb-4">Smart Vendor Queue & Order Management</h1>
                <p class="lead text-muted mb-5">Digital ordering and First-Come-First-Serve (FCFS) queue management for college canteens, juice centers, and food stalls.</p>
                <div>
                    <a href="login.jsp" class="btn btn-primary btn-lg px-4 me-3 mt-2">Get Started</a>
                    <a href="register.jsp" class="btn btn-outline-secondary btn-lg px-4 mt-2">Vendor Registration</a>
                </div>
            </div>
        </section>

        <!-- Features Section -->
        <section class="py-5 bg-white">
            <div class="container">
                <div class="row text-center mt-4">
                    <div class="col-md-4 mb-4">
                        <i class="bi bi-qr-code feature-icon"></i>
                        <h3 class="h5 fw-bold">Digital Menu</h3>
                        <p class="text-muted">Customers can browse live menus and place orders without standing in physical lines.</p>
                    </div>
                    <div class="col-md-4 mb-4">
                        <i class="bi bi-ticket-perforated feature-icon"></i>
                        <h3 class="h5 fw-bold">Auto Token Generation</h3>
                        <p class="text-muted">Get a unique daily token number. Vendors prepare orders based on FCFS.</p>
                    </div>
                    <div class="col-md-4 mb-4">
                        <i class="bi bi-graph-up-arrow feature-icon"></i>
                        <h3 class="h5 fw-bold">Vendor Dashboard</h3>
                        <p class="text-muted">Manage menus, live queues, order history, and view revenue analytics.</p>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <jsp:include page="/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/main.js"></script>
</body>
</html>

