/* Main JS file for VendorFlow */

document.addEventListener("DOMContentLoaded", function() {
    // Auto-dismiss alerts after 5 seconds
    const alerts = document.querySelectorAll('.alert:not(.alert-permanent)');
    alerts.forEach(function(alert) {
        setTimeout(function() {
            let bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }, 5000);
    });

    // Form validation enforcement for Bootstrap
    var forms = document.querySelectorAll('.needs-validation');
    Array.prototype.slice.call(forms).forEach(function (form) {
        form.addEventListener('submit', function (event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        }, false);
    });
});

/**
 * Handle Add to Cart via AJAX to avoid full page reload where possible,
 * or just let the default form submission happen (simpler for basic Servlet).
 */
function confirmDelete(message) {
    return innerConfirm(message || "Are you sure you want to delete this?");
}

function innerConfirm(msg) {
    return confirm(msg);
}
