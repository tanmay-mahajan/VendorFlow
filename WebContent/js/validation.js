function toggleVendorFields() {
    var role = document.getElementById("roleSelect").value;
    var vendorFields = document.getElementById("vendorFields");
    var shopName = document.getElementById("shopName");

    if (role === "vendor") {
        vendorFields.style.display = "block";
        shopName.setAttribute("required", "true");
    } else {
        vendorFields.style.display = "none";
        shopName.removeAttribute("required");
        shopName.classList.remove("is-invalid", "is-valid");
    }
}

function setInvalidState(input, isInvalid) {
    input.classList.remove("is-valid");
    if (isInvalid) {
        input.classList.add("is-invalid");
    } else {
        input.classList.remove("is-invalid");
    }
}

function validateName(input) {
    var value = input.value.trim();
    var isInvalid = value.length > 0 && !/^[A-Za-z ]{3,}$/.test(value);
    setInvalidState(input, isInvalid);
}

function validateEmail(input) {
    var value = input.value.trim();
    var isInvalid = value.length > 0 && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
    setInvalidState(input, isInvalid);
}

function validatePhone(input) {
    input.value = input.value.replace(/\D/g, "").slice(0, 10);
    var value = input.value;
    var isInvalid = value.length > 0 && !/^\d{10}$/.test(value);
    setInvalidState(input, isInvalid);
}

function validatePassword(input) {
    var value = input.value;
    var isInvalid = value.length > 0 && value.length < 6;
    setInvalidState(input, isInvalid);
}
