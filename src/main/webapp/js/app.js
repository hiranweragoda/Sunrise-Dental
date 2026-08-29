// Traditional Java Web MVC Client Utility Functions

document.addEventListener('DOMContentLoaded', () => {
    setMinDate();
    initTabNavigation();
    calculateCashBalance();
});

// Set minimum date on appointment date pickers to today
function setMinDate() {
    const dateInput = document.getElementById('appointment_date');
    if (dateInput) {
        const today = new Date().toISOString().split('T')[0];
        dateInput.min = today;
    }
    const updateDateInput = document.getElementById('update_appointment_date');
    if (updateDateInput) {
        const today = new Date().toISOString().split('T')[0];
        updateDateInput.min = today;
    }
}

// Client-side Tab Navigation Handler
function switchTab(tabId) {
    // Hide all tab contents
    document.querySelectorAll('.tab-content').forEach(section => {
        section.classList.remove('active');
    });

    // Remove active class from all nav items
    document.querySelectorAll('.sidebar .nav-item').forEach(button => {
        button.classList.remove('active');
    });

    // Activate selected tab content
    const selectedTab = document.getElementById(tabId);
    if (selectedTab) {
        selectedTab.classList.add('active');
    }

    // Activate corresponding sidebar nav button
    const targetNavBtn = document.querySelector(`.sidebar .nav-item[onclick*="${tabId}"]`);
    if (targetNavBtn) {
        targetNavBtn.classList.add('active');
    }
}

function initTabNavigation() {
    // Check URL parameters for active tab
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams.get('tab');
    if (tabParam) {
        switchTab(tabParam);
    }
}

// Calculate Cash Balance and Update Total Bill
function calculateCashBalance() {
    const consultationInput = document.getElementById('consultation_fee');
    const treatmentCostInput = document.getElementById('treatment_cost_val');
    const cashGivenInput = document.getElementById('cash_given');
    
    const calcTotalSpan = document.getElementById('calc_total_cost');
    const calcBalanceSpan = document.getElementById('calc_balance');
    const balanceReturnedHidden = document.getElementById('balance_returned');
    const cashErrorMsg = document.getElementById('cash_error_msg');
    const submitBtn = document.getElementById('btn-submit-payment');

    const consultationFee = parseFloat(consultationInput ? consultationInput.value : 0) || 0;
    const treatmentCost = parseFloat(treatmentCostInput ? treatmentCostInput.value : 0) || 0;
    const cashGiven = parseFloat(cashGivenInput ? cashGivenInput.value : 0) || 0;

    const totalBill = treatmentCost + consultationFee;
    if (calcTotalSpan) {
        calcTotalSpan.textContent = totalBill.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    const isCashChecked = document.getElementById('method-cash') && document.getElementById('method-cash').checked;
    if (isCashChecked) {
        const balance = cashGiven - totalBill;
        if (cashGiven > 0) {
            if (balance >= 0) {
                if (calcBalanceSpan) {
                    calcBalanceSpan.textContent = 'LKR ' + balance.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                    calcBalanceSpan.style.color = '#4ade80';
                }
                if (balanceReturnedHidden) balanceReturnedHidden.value = balance.toFixed(2);
                if (cashErrorMsg) cashErrorMsg.style.display = 'none';
                if (submitBtn) submitBtn.disabled = false;
            } else {
                if (calcBalanceSpan) {
                    calcBalanceSpan.textContent = 'Insufficient Cash';
                    calcBalanceSpan.style.color = '#f87171';
                }
                if (balanceReturnedHidden) balanceReturnedHidden.value = '0.00';
                if (cashErrorMsg) {
                    cashErrorMsg.textContent = '⚠️ Cash given (LKR ' + cashGiven.toFixed(2) + ') is less than total bill (LKR ' + totalBill.toFixed(2) + ')';
                    cashErrorMsg.style.display = 'block';
                }
            }
        } else {
            if (calcBalanceSpan) {
                calcBalanceSpan.textContent = 'LKR 0.00';
                calcBalanceSpan.style.color = '#4ade80';
            }
            if (balanceReturnedHidden) balanceReturnedHidden.value = '0.00';
            if (cashErrorMsg) cashErrorMsg.style.display = 'none';
        }
    }
}

// Switch between Cash and Card payment forms
function switchPaymentMethod(method) {
    const cashSection = document.getElementById('cash-payment-section');
    const cardSection = document.getElementById('card-payment-section');
    const cashGivenInput = document.getElementById('cash_given');
    
    if (method === 'Cash') {
        if (cashSection) cashSection.style.display = 'block';
        if (cardSection) cardSection.style.display = 'none';
        if (cashGivenInput) cashGivenInput.required = true;
    } else if (method === 'Card') {
        if (cashSection) cashSection.style.display = 'none';
        if (cardSection) cardSection.style.display = 'block';
        if (cashGivenInput) cashGivenInput.required = false;
    }
    calculateCashBalance();
}

// Format Card Number (adds spaces every 4 digits)
function formatCardNumber(input) {
    let value = input.value.replace(/\D/g, '');
    let formatted = '';
    for (let i = 0; i < value.length; i++) {
        if (i > 0 && i % 4 === 0) formatted += ' ';
        formatted += value[i];
    }
    input.value = formatted;
}

// Format Card Expiry (MM/YY)
function formatCardExpiry(input) {
    let value = input.value.replace(/\D/g, '');
    if (value.length >= 2) {
        input.value = value.substring(0, 2) + '/' + value.substring(2, 4);
    } else {
        input.value = value;
    }
}

// Toggle Inline Appointment Update Form
function toggleApptUpdateForm() {
    const form = document.getElementById('appt-update-form');
    if (form) {
        form.style.display = (form.style.display === 'none' || form.style.display === '') ? 'block' : 'none';
        if (form.style.display === 'block') {
            form.scrollIntoView({ behavior: 'smooth' });
        }
    }
}

// Handle Data Attributes for Edit
function handleEditPatient(btn) {
    const id = btn.getAttribute('data-id');
    const name = btn.getAttribute('data-name');
    const nic = btn.getAttribute('data-nic');
    const phone = btn.getAttribute('data-phone');
    const address = btn.getAttribute('data-address');
    editPatient(id, name, nic, phone, address);
}

function handleEditUser(btn) {
    const id = btn.getAttribute('data-id');
    const username = btn.getAttribute('data-username');
    const fullname = btn.getAttribute('data-fullname');
    const role = btn.getAttribute('data-role');
    editUser(id, username, fullname, role);
}

function handleEditDentist(btn) {
    const id = btn.getAttribute('data-id');
    const name = btn.getAttribute('data-name');
    const spec = btn.getAttribute('data-spec');
    const contact = btn.getAttribute('data-contact');
    editDentist(id, name, spec, contact);
}

function handleEditTreatment(btn) {
    const id = btn.getAttribute('data-id');
    const name = btn.getAttribute('data-name');
    const cost = btn.getAttribute('data-cost');
    editTreatment(id, name, cost);
}

// Edit populate functions
function editPatient(id, name, nic, phone, address) {
    switchTab('tab-patients');
    const idInput = document.getElementById('patient-id');
    if (idInput) idInput.value = id;
    const nameInput = document.getElementById('patient-name-input');
    if (nameInput) nameInput.value = name;
    const nicInput = document.getElementById('patient-nic-input');
    if (nicInput) nicInput.value = nic;
    const phoneInput = document.getElementById('patient-phone-input');
    if (phoneInput) phoneInput.value = phone;
    const addrInput = document.getElementById('patient-address-input');
    if (addrInput) addrInput.value = address || '';
    
    const submitBtn = document.querySelector('#tab-patients form button[type="submit"]');
    if (submitBtn) submitBtn.textContent = 'Update Patient Profile';
    if (nameInput) nameInput.focus();
}

function editUser(id, username, fullName, role) {
    switchTab('tab-users');
    const idInput = document.getElementById('user-id');
    if (idInput) idInput.value = id;
    const userInput = document.getElementById('user-username');
    if (userInput) userInput.value = username;
    const fullInput = document.getElementById('user-fullname');
    if (fullInput) fullInput.value = fullName;
    const roleInput = document.getElementById('user-role');
    if (roleInput) roleInput.value = role;

    const pwdInput = document.getElementById('user-password');
    if (pwdInput) pwdInput.placeholder = '(Leave blank to keep current password)';

    const submitBtn = document.querySelector('#tab-users form button[type="submit"]');
    if (submitBtn) submitBtn.textContent = 'Update User Account';
    if (userInput) userInput.focus();
}

function editDentist(id, name, specialization, contact) {
    switchTab('tab-dentists');
    const idInput = document.getElementById('dentist-id');
    if (idInput) idInput.value = id;
    const nameInput = document.getElementById('dentist-name-input');
    if (nameInput) nameInput.value = name;
    const specInput = document.getElementById('dentist-specialization');
    if (specInput) specInput.value = specialization;
    const contactInput = document.getElementById('dentist-contact');
    if (contactInput) contactInput.value = contact || '';

    const submitBtn = document.querySelector('#tab-dentists form button[type="submit"]');
    if (submitBtn) submitBtn.textContent = 'Update Dentist Profile';
    if (nameInput) nameInput.focus();
}

function editTreatment(id, name, cost) {
    switchTab('tab-treatments');
    const idInput = document.getElementById('treatment-id-input');
    if (idInput) idInput.value = id;
    const nameInput = document.getElementById('treatment-name-input');
    if (nameInput) nameInput.value = name;
    const costInput = document.getElementById('treatment-cost-input');
    if (costInput) costInput.value = cost;

    const submitBtn = document.querySelector('#tab-treatments form button[type="submit"]');
    if (submitBtn) submitBtn.textContent = 'Update Treatment Service';
    if (nameInput) nameInput.focus();
}

// Form reset helper functions
function resetPatientForm() {
    const form = document.querySelector('#tab-patients form');
    if (form) {
        form.reset();
        const idInput = document.getElementById('patient-id');
        if (idInput) idInput.value = '0';
        const submitBtn = form.querySelector('button[type="submit"]');
        if (submitBtn) submitBtn.textContent = 'Save Patient Profile';
    }
}

function resetDentistForm() {
    const form = document.querySelector('#tab-dentists form');
    if (form) {
        form.reset();
        const idInput = document.getElementById('dentist-id');
        if (idInput) idInput.value = '0';
        const submitBtn = form.querySelector('button[type="submit"]');
        if (submitBtn) submitBtn.textContent = 'Save Dentist Profile';
    }
}

function resetTreatmentForm() {
    const form = document.querySelector('#tab-treatments form');
    if (form) {
        form.reset();
        const idInput = document.getElementById('treatment-id-input');
        if (idInput) idInput.value = '0';
        const submitBtn = form.querySelector('button[type="submit"]');
        if (submitBtn) submitBtn.textContent = 'Save Treatment Service';
    }
}

function resetUserForm() {
    const form = document.querySelector('#tab-users form');
    if (form) {
        form.reset();
        const idInput = document.getElementById('user-id');
        if (idInput) idInput.value = '0';
        const submitBtn = form.querySelector('button[type="submit"]');
        if (submitBtn) submitBtn.textContent = 'Save User Account';
        const pwdInput = document.getElementById('user-password');
        if (pwdInput) pwdInput.placeholder = '••••••••';
    }
}

// System Logout redirect
function handleLogout() {
    window.location.href = 'logout';
}

// Fetch & Render Live Interactive Time Slots
const STANDARD_CLINIC_SLOTS = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00"
];

function fetchAvailableTimeSlots() {
    const dentistSelect = document.getElementById('dentist_name');
    const dateInput = document.getElementById('appointment_date');
    const promptMsg = document.getElementById('slots-prompt-msg');
    const grid = document.getElementById('slots-grid');

    if (!grid) return;

    const dentist = dentistSelect ? dentistSelect.value : '';
    const date = dateInput ? dateInput.value : '';

    if (!dentist || !date) {
        if (promptMsg) promptMsg.textContent = 'Please select a Dentist and Date above to select a time slot.';
        grid.innerHTML = '';
        return;
    }

    if (promptMsg) promptMsg.textContent = `Standard clinic time slots for ${dentist} on ${date}:`;
    grid.innerHTML = '';

    STANDARD_CLINIC_SLOTS.forEach(slot => {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.style.padding = '8px 14px';
        btn.style.borderRadius = '8px';
        btn.style.fontSize = '0.85rem';
        btn.style.fontWeight = '600';
        btn.style.border = 'none';
        btn.style.cursor = 'pointer';
        btn.style.transition = 'all 0.2s ease';
        btn.innerHTML = `🟢 ${slot} <span style="font-size: 0.75rem; opacity: 0.9;">(Select)</span>`;
        btn.style.background = 'rgba(34, 197, 94, 0.15)';
        btn.style.color = '#15803d';
        btn.style.border = '1px solid rgba(34, 197, 94, 0.4)';
        btn.onclick = () => selectTimeSlot(slot, btn);
        grid.appendChild(btn);
    });
}

function selectTimeSlot(slot, clickedBtn) {
    const timeInput = document.getElementById('appointment_time');
    if (timeInput) {
        timeInput.value = slot;
    }
    document.querySelectorAll('#slots-grid button').forEach(btn => {
        if (!btn.disabled) {
            btn.style.background = 'rgba(34, 197, 94, 0.15)';
            btn.style.color = '#4ade80';
            btn.style.borderColor = 'rgba(34, 197, 94, 0.4)';
            btn.style.transform = 'scale(1)';
        }
    });
    if (clickedBtn) {
        clickedBtn.style.background = '#22c55e';
        clickedBtn.style.color = '#000000';
        clickedBtn.style.transform = 'scale(1.05)';
    }
}

