<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("userId") == null || !"vendor".equals(session.getAttribute("userRole"))) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Analytics Dashboard - VendorFlow</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <jsp:include page="/common/navbar.jsp" />

    <main class="container py-4">
        <h2 class="fw-bold mb-4">Analytics & Reports</h2>

        <div id="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-2 text-muted">Loading analytics...</p>
        </div>

        <div id="dashboardContent" style="display: none;">
            <!-- Key Metric Cards -->
            <div class="row g-3 mb-4 text-center">
                <div class="col-md-3">
                    <div class="card shadow-sm border-0 bg-light"><div class="card-body">
                        <div class="text-muted small text-uppercase fw-bold">Total Orders</div>
                        <h3 class="mb-0 text-dark" id="mTotalOrders">0</h3>
                    </div></div>
                </div>
                <div class="col-md-3">
                    <div class="card shadow-sm border-0 bg-light"><div class="card-body">
                        <div class="text-muted small text-uppercase fw-bold">Total Revenue</div>
                        <h3 class="mb-0 text-success">₹<span id="mTotalRev">0</span></h3>
                    </div></div>
                </div>
                <div class="col-md-3">
                    <div class="card shadow-sm border-0 bg-light"><div class="card-body">
                        <div class="text-muted small text-uppercase fw-bold">Unique Customers</div>
                        <h3 class="mb-0 text-primary" id="mCustomers">0</h3>
                    </div></div>
                </div>
                <div class="col-md-3">
                    <div class="card shadow-sm border-0 bg-light"><div class="card-body">
                        <div class="text-muted small text-uppercase fw-bold">Completed Today</div>
                        <h3 class="mb-0 text-info" id="mCompletedToday">0</h3>
                    </div></div>
                </div>
            </div>

            <!-- Charts Row 1 -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8">
                    <div class="card shadow-sm h-100">
                        <div class="card-header bg-white"><h5 class="mb-0 fw-bold">Weekly Order Trend</h5></div>
                        <div class="card-body"><canvas id="chartWeekly"></canvas></div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="card shadow-sm h-100">
                        <div class="card-header bg-white"><h5 class="mb-0 fw-bold">Top Selling Items</h5></div>
                        <div class="card-body"><canvas id="chartTopItems"></canvas></div>
                    </div>
                </div>
            </div>

            <!-- Charts Row 2 -->
            <div class="row g-4 mb-4">
                <div class="col-lg-6">
                    <div class="card shadow-sm h-100">
                        <div class="card-header bg-white"><h5 class="mb-0 fw-bold">Today's Peak Hours</h5></div>
                        <div class="card-body"><canvas id="chartPeakHours"></canvas></div>
                    </div>
                </div>
                 <div class="col-lg-6">
                    <div class="card shadow-sm h-100">
                        <div class="card-header bg-white"><h5 class="mb-0 fw-bold">Order Status Summary (Today)</h5></div>
                        <div class="card-body d-flex justify-content-center" style="max-height: 300px;">
                            <canvas id="chartStatus"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            fetch('<%=request.getContextPath()%>/AnalyticsServlet')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('loading').style.display = 'none';
                    document.getElementById('dashboardContent').style.display = 'block';

                    // Update metrics
                    document.getElementById('mTotalOrders').textContent = data.totalOrders;
                    document.getElementById('mTotalRev').textContent = data.totalRevenue;
                    document.getElementById('mCustomers').textContent = data.totalCustomers;
                    document.getElementById('mCompletedToday').textContent = data.completedOrders;

                    // Chart: Weekly Orders (Line)
                    const labelDays = Object.keys(data.ordersPerDay);
                    const dataDays  = Object.values(data.ordersPerDay);
                    new Chart(document.getElementById('chartWeekly'), {
                        type: 'line',
                        data: {
                            labels: labelDays,
                            datasets: [{
                                label: 'Orders (This Week)',
                                data: dataDays,
                                borderColor: '#2196F3',
                                fill: true,
                                backgroundColor: 'rgba(33, 150, 243, 0.1)',
                                tension: 0.3
                            }]
                        }
                    });

                    // Chart: Top Items (Bar)
                    const labelItems = Object.keys(data.topItems);
                    const dataItems  = Object.values(data.topItems);
                    new Chart(document.getElementById('chartTopItems'), {
                        type: 'bar',
                        data: {
                            labels: labelItems,
                            datasets: [{
                                label: 'Units Sold',
                                data: dataItems,
                                backgroundColor: '#4CAF50'
                            }]
                        },
                        options: { indexAxis: 'y' } 
                    });

                    // Chart: Peak Hours (Bar)
                    const labelHours = Object.keys(data.peakHours);
                    const dataHours  = Object.values(data.peakHours);
                    new Chart(document.getElementById('chartPeakHours'), {
                        type: 'bar',
                        data: {
                            labels: labelHours,
                            datasets: [{
                                label: 'Orders',
                                data: dataHours,
                                backgroundColor: '#FF9800'
                            }]
                        }
                    });

                    // Chart: Status (Doughnut)
                    new Chart(document.getElementById('chartStatus'), {
                        type: 'doughnut',
                        data: {
                            labels: ['Pending', 'Completed'],
                            datasets: [{
                                data: [data.pendingOrders, data.completedOrders],
                                backgroundColor: ['#fa983a', '#0c2461']
                            }]
                        }
                    });
                })
                .catch(err => {
                    document.getElementById('loading').innerHTML = '<div class="alert alert-danger">Error loading analytics. Check console.</div>';
                    console.error('Analytics Error:', err);
                });
        });
    </script>
</body>
</html>

