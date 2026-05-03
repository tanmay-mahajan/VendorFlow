/* Main JS file for VendorFlow */

document.addEventListener("DOMContentLoaded", function() {
    // Initialize Toast system
    const toastContainer = document.createElement('div');
    toastContainer.id = 'toast-container';
    toastContainer.className = 'toast-container position-fixed bottom-0 end-0 p-3';
    document.body.appendChild(toastContainer);

    // Auto-dismiss alerts after 5 seconds
    const alerts = document.querySelectorAll('.alert:not(.alert-permanent)');
    alerts.forEach(function(alert) {
        setTimeout(function() {
            let bsAlert = new bootstrap.Alert(alert);
            if (bsAlert) bsAlert.close();
        }, 5000);
    });

    // Form validation enforcement
    const forms = document.querySelectorAll('.needs-validation');
    forms.forEach(function (form) {
        form.addEventListener('submit', function (event) {
            let isValid = true;
            
            // Custom Validation Logic
            const emailInput = form.querySelector('input[type="email"]');
            const phoneInput = form.querySelector('input[name="phone"]');
            const nameInput = form.querySelector('input[name="name"]');
            
            if (emailInput && !validateEmail(emailInput.value)) {
                showToast("Please enter a valid email address", "danger");
                isValid = false;
            }
            
            if (phoneInput && phoneInput.value.length !== 10 && phoneInput.value.length > 0) {
                showToast("Phone number must be exactly 10 digits", "danger");
                isValid = false;
            }
            
            if (nameInput && nameInput.value.length < 3) {
                showToast("Name must be at least 3 characters long", "danger");
                isValid = false;
            }

            if (!form.checkValidity() || !isValid) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        }, false);
    });
});

function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(String(email).toLowerCase());
}

function showToast(message, type = "primary") {
    const container = document.getElementById('toast-container');
    const toastEl = document.createElement('div');
    toastEl.className = `toast align-items-center text-white bg-${type} border-0 show`;
    toastEl.setAttribute('role', 'alert');
    toastEl.setAttribute('aria-live', 'assertive');
    toastEl.setAttribute('aria-atomic', 'true');
    
    toastEl.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">${message}</div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    `;
    
    container.appendChild(toastEl);
    setTimeout(() => {
        toastEl.classList.remove('show');
        setTimeout(() => toastEl.remove(), 500);
    }, 4000);
}

function confirmDelete(message) {
    return confirm(message || "Are you sure you want to delete this?");
}
