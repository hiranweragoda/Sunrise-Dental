<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.model.*" %>
<%@ page import="java.util.List" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String role = currentUser.getRole();
    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.trim().isEmpty()) {
        activeTab = "tab-register";
    }

    List<Patient> patients = (List<Patient>) request.getAttribute("patients");
    List<Dentist> dentists = (List<Dentist>) request.getAttribute("dentists");
    List<Treatment> treatments = (List<Treatment>) request.getAttribute("treatments");
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    List<User> users = (List<User>) request.getAttribute("users");

    Patient verifiedPatient = (Patient) request.getAttribute("verifiedPatient");
    String verifySuccess = (String) request.getAttribute("verifySuccess");
    String verifyError = (String) request.getAttribute("verifyError");

    Appointment searchedAppointment = (Appointment) request.getAttribute("searchedAppointment");
    String searchSuccess = (String) request.getAttribute("searchSuccess");
    String searchError = (String) request.getAttribute("searchError");
    String enteredApptNum = request.getParameter("search_appt_num");

    Appointment selectedBillAppt = (Appointment) request.getAttribute("selectedBillAppt");
    String billApptError = (String) request.getAttribute("billApptError");
    String enteredBillApptNum = request.getParameter("bill_appt_num");

    String flashSuccess = (String) request.getAttribute("flashSuccess");
    String flashError = (String) request.getAttribute("flashError");
    
    String enteredNic = request.getParameter("nic");
    if (enteredNic == null && verifiedPatient != null) enteredNic = verifiedPatient.getNicPassport();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Sunrise Dental Management (MVC)</title>
    <link rel="stylesheet" href="css/style.css?v=8">
    <style>
        .highlight-row { background: rgba(56, 189, 248, 0.15) !important; }
    </style>
</head>
<body class="dashboard-body">

    <!-- Top Navigation Bar -->
    <header class="top-nav">
        <div class="brand">
            <span class="logo-icon">🦷</span>
            <span class="brand-title">Sunrise Dental Clinic Management</span>
        </div>
        <div class="user-profile">
            <div class="user-avatar"><%= currentUser.getFullName().substring(0, 1).toUpperCase() %></div>
            <div class="user-info">
                <span class="user-name"><%= currentUser.getFullName() %></span>
                <span class="user-role"><%= role %></span>
            </div>
        </div>
    </header>

    <div class="main-wrapper">
        <!-- Sidebar Navigation -->
        <aside class="sidebar">
            <a href="dashboard?tab=tab-register" onclick="switchTab('tab-register'); return false;" id="nav-tab-register" class="nav-item <%= "tab-register".equals(activeTab) ? "active" : "" %>">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                </svg>
                <span>New Appointment</span>
            </a>
            <a href="dashboard?tab=tab-patients" onclick="switchTab('tab-patients'); return false;" id="nav-tab-patients" class="nav-item <%= "tab-patients".equals(activeTab) ? "active" : "" %>">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
                <span>Patient Registration</span>
            </a>
            <a href="dashboard?tab=tab-search" onclick="switchTab('tab-search'); return false;" id="nav-tab-search" class="nav-item <%= "tab-search".equals(activeTab) ? "active" : "" %>">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <span>Search Details</span>
            </a>
            <a href="dashboard?tab=tab-billing" onclick="switchTab('tab-billing'); return false;" id="nav-tab-billing" class="nav-item <%= "tab-billing".equals(activeTab) ? "active" : "" %>">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                </svg>
                <span>Calculate & Bill</span>
            </a>
            <% if ("Admin".equals(role)) { %>
            <a href="dashboard?tab=tab-users" onclick="switchTab('tab-users'); return false;" id="nav-tab-users" class="nav-item <%= "tab-users".equals(activeTab) ? "active" : "" %>">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
                <span>User Management</span>
            </a>
            <a href="dashboard?tab=tab-dentists" onclick="switchTab('tab-dentists'); return false;" id="nav-tab-dentists" class="nav-item <%= "tab-dentists".equals(activeTab) ? "active" : "" %>">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                <span>Dentist Management</span>
            </a>
            <a href="dashboard?tab=tab-treatments" onclick="switchTab('tab-treatments'); return false;" id="nav-tab-treatments" class="nav-item <%= "tab-treatments".equals(activeTab) ? "active" : "" %>">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L5.605 15.13a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" />
                </svg>
                <span>Treatment Packages</span>
            </a>
            <a href="reports" class="nav-item">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
                <span>Analytics & Reports</span>
            </a>
            <% } %>

            <a href="dashboard?tab=tab-help" onclick="switchTab('tab-help'); return false;" id="nav-tab-help" class="nav-item <%= "tab-help".equals(activeTab) ? "active" : "" %>">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>Help Section</span>
            </a>

            <a href="logout" class="nav-item logout">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
                <span>Exit System</span>
            </a>
        </aside>

        <!-- Main Content Area -->
        <main class="content-area">

            <!-- Flash Alert Box -->
            <% if (flashSuccess != null) { %>
                <div class="alert alert-success" style="display: flex; margin-bottom: 1.5rem;">
                    <span>✓</span><span><%= flashSuccess %></span>
                </div>
            <% } %>
            <% if (flashError != null) { %>
                <div class="alert alert-error" style="display: flex; margin-bottom: 1.5rem;">
                    <span>⚠️</span><span><%= flashError %></span>
                </div>
            <% } %>

            <!-- TAB 1: REGISTER APPOINTMENT -->
            <section id="tab-register" class="tab-content <%= "tab-register".equals(activeTab) ? "active" : "" %>">
                <div class="panel">
                    <div class="panel-header">
                        <h2 class="panel-title">Register Appointment</h2>
                        <p class="panel-subtitle">Create a new patient checkup schedule</p>
                    </div>

                    <!-- Step 1: NIC Search Form -->
                    <form action="dashboard" method="GET" style="margin-bottom: 1.5rem;">
                        <input type="hidden" name="tab" value="tab-register">
                        <div class="form-group full-width">
                            <label for="search_patient_nic">Patient NIC / Passport Number <span style="font-weight: 500; font-size: 0.8rem; color: #0284c7;">(Enter NIC or Passport and click Verify Patient)</span></label>
                            <div style="display: flex; gap: 10px;">
                                <input type="text" id="search_patient_nic" name="nic" value="<%= enteredNic != null ? enteredNic : "" %>" placeholder="e.g. 199512345678 or N1234567" required style="flex: 1;">
                                <button type="submit" class="btn btn-secondary">Verify Patient</button>
                            </div>
                            <% if (verifySuccess != null) { %>
                                <small style="display: block; margin-top: 6px; font-size: 0.85rem; font-weight: 500; color: #16a34a;"><%= verifySuccess %></small>
                            <% } else if (verifyError != null) { %>
                                <small style="display: block; margin-top: 6px; font-size: 0.85rem; font-weight: 500; color: #dc2626;"><%= verifyError %></small>
                            <% } %>
                        </div>
                    </form>

                    <!-- Step 2: Appointment Form -->
                    <form action="appointments" method="POST">
                        <input type="hidden" name="search_patient_nic" value="<%= enteredNic != null ? enteredNic : "" %>">
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="patient_name">Patient Full Name</label>
                                <input type="text" id="patient_name" value="<%= verifiedPatient != null ? verifiedPatient.getPatientName() : "" %>" placeholder="Auto-filled from registered patient" required readonly style="background: #e2e8f0; color: #334155; font-weight: 600;">
                            </div>

                            <div class="form-group">
                                <label for="contact_number">Contact Number</label>
                                <input type="tel" id="contact_number" value="<%= verifiedPatient != null ? verifiedPatient.getPhoneNumber() : "" %>" placeholder="Auto-filled" required readonly style="background: #e2e8f0; color: #334155; font-weight: 600;">
                            </div>

                            <div class="form-group full-width">
                                <label for="address">Address</label>
                                <input type="text" id="address" value="<%= (verifiedPatient != null && verifiedPatient.getAddress() != null) ? verifiedPatient.getAddress() : "" %>" placeholder="Auto-filled address" readonly style="background: #e2e8f0; color: #334155; font-weight: 600;">
                            </div>

                            <div class="form-group">
                                <label for="dentist_name">Dentist Name</label>
                                <select id="dentist_name" name="dentist_name" required onchange="fetchAvailableTimeSlots()">
                                    <option value="" disabled selected>Select a Dentist</option>
                                    <% if (dentists != null) { for (Dentist d : dentists) { %>
                                        <option value="<%= d.getDentistName() %>"><%= d.getDentistName() %> (<%= d.getSpecialization() %>)</option>
                                    <% } } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="treatment_id">Treatment Service</label>
                                <select id="treatment_id" name="treatment_id" required>
                                    <option value="" disabled selected>Select a Service</option>
                                    <% if (treatments != null) { for (Treatment t : treatments) { %>
                                        <option value="<%= t.getId() %>"><%= t.getTreatmentName() %> - LKR <%= String.format("%,.2f", t.getCost()) %></option>
                                    <% } } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="appointment_date">Appointment Date</label>
                                <input type="date" id="appointment_date" name="appointment_date" required onchange="fetchAvailableTimeSlots()">
                            </div>

                            <div class="form-group">
                                <label for="appointment_time">Appointment Time <span style="font-size: 0.8rem; color: #0284c7;">(Select slot below or type time)</span></label>
                                <input type="time" id="appointment_time" name="appointment_time" required>
                            </div>

                            <div class="form-group full-width" id="time-slots-container" style="background: #f8fafc; padding: 1.25rem; border-radius: 12px; border: 1px solid #cbd5e1; margin-top: 0.5rem;">
                                <label style="margin-bottom: 0.5rem; display: block; font-weight: 700; color: #0284c7;">⏰ Interactive Doctor Availability & Live Time Slots</label>
                                <p style="font-size: 0.85rem; color: #475569; margin-bottom: 0.75rem;" id="slots-prompt-msg">Please select a Dentist and Date above to view live time slot availability.</p>
                                <div id="slots-grid" style="display: flex; flex-wrap: wrap; gap: 0.6rem;"></div>
                            </div>
                        </div>

                        <div class="form-actions" style="margin-top: 1.5rem;">
                            <a href="dashboard?tab=tab-register" class="btn btn-secondary">Clear Fields</a>
                            <button type="submit" class="btn btn-primary">Register Appointment</button>
                        </div>
                    </form>
                </div>
            </section>

            <!-- TAB 2: PATIENT MANAGEMENT (STAFF & ADMIN) -->
            <section id="tab-patients" class="tab-content <%= "tab-patients".equals(activeTab) ? "active" : "" %>">
                <div class="panel">
                    <div class="panel-header">
                        <h2 class="panel-title">Patient Profile Registration & Management</h2>
                        <p class="panel-subtitle">Register new patients with NIC/Passport details, edit records, or remove patient profiles</p>
                    </div>

                    <form action="patients" method="POST">
                        <input type="hidden" id="patient-id" name="id" value="0">
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="patient-name-input">Patient Full Name</label>
                                <input type="text" id="patient-name-input" name="patient_name" placeholder="e.g. Nimal Perera" required minlength="3">
                            </div>

                            <div class="form-group">
                                <label for="patient-nic-input">NIC / Passport Number</label>
                                <input type="text" id="patient-nic-input" name="nic_passport" placeholder="e.g. 199512345678 or N1234567" required minlength="5">
                            </div>

                            <div class="form-group">
                                <label for="patient-phone-input">Contact Phone Number</label>
                                <input type="tel" id="patient-phone-input" name="phone_number" placeholder="e.g. 0771234567" required>
                            </div>

                            <div class="form-group">
                                <label for="patient-address-input">Residential Address</label>
                                <input type="text" id="patient-address-input" name="address" placeholder="e.g. 45 Temple Road, Nugegoda">
                            </div>
                        </div>

                        <div class="form-actions" style="margin-top: 1.5rem;">
                            <button type="button" class="btn btn-secondary" onclick="resetPatientForm()">Clear Form</button>
                            <button type="submit" class="btn btn-primary">Save Patient Profile</button>
                        </div>
                    </form>

                </div> <!-- End Form Card Panel -->

                <!-- Separate Panel Card for Patients Directory Table -->
                <div class="panel" style="margin-top: 1.75rem;">
                    <div class="panel-header">
                        <h2 class="panel-title">Registered Clinic Patients Directory</h2>
                        <p class="panel-subtitle">Complete list of registered clinic patients, NIC numbers, and contact details</p>
                    </div>
                    <div style="overflow-x: auto; border-radius: 12px; border: 1px solid #e2e8f0;">
                        <table class="report-table" style="margin-top: 0;">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Patient Name</th>
                                    <th>NIC / Passport</th>
                                    <th>Contact Phone</th>
                                    <th>Address</th>
                                    <th style="text-align: right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (patients != null && !patients.isEmpty()) { for (Patient p : patients) { %>
                                    <tr>
                                        <td><%= p.getId() %></td>
                                        <td style="font-weight: 600;"><%= p.getPatientName() %></td>
                                        <td><span style="font-family: monospace; background: #f1f5f9; color: #0f172a; padding: 2px 8px; border-radius: 4px; font-weight: 600;"><%= p.getNicPassport() %></span></td>
                                        <td><%= p.getPhoneNumber() %></td>
                                        <td><%= p.getAddress() != null ? p.getAddress() : "-" %></td>
                                        <td style="text-align: right;">
                                            <button type="button" class="btn btn-secondary" style="padding: 4px 10px; font-size: 0.8rem; margin-right: 4px;" data-id="<%= p.getId() %>" data-name="<%= p.getPatientName() %>" data-nic="<%= p.getNicPassport() %>" data-phone="<%= p.getPhoneNumber() %>" data-address="<%= p.getAddress() != null ? p.getAddress() : "" %>" onclick="handleEditPatient(this)">Edit</button>
                                            <a href="patients?action=delete&id=<%= p.getId() %>" class="btn btn-danger" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Delete patient <%= p.getPatientName() %>?')">Delete</a>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="6" style="text-align: center; color: #64748b;">No registered patients found.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- TAB 3: SEARCH DETAILS & APPOINTMENT SEARCH -->
            <section id="tab-search" class="tab-content <%= "tab-search".equals(activeTab) ? "active" : "" %>">
                <div class="panel">
                    <div class="panel-header">
                        <h2 class="panel-title">Appointments Directory & Search Details</h2>
                        <p class="panel-subtitle">Search complete patient and appointment details by Appointment Number or view schedules</p>
                    </div>

                    <!-- Search Form by Appointment Number -->
                    <form action="dashboard" method="GET" style="margin-bottom: 2rem;">
                        <input type="hidden" name="tab" value="tab-search">
                        <div class="form-group full-width">
                            <label for="search_appt_num">Search Appointment by Appointment Number <span style="font-weight: normal; font-size: 0.8rem; color: #38bdf8;">(Enter Appointment # e.g. APPT-1001 or APT-76201)</span></label>
                            <div style="display: flex; gap: 10px;">
                                <input type="text" id="search_appt_num" name="search_appt_num" value="<%= enteredApptNum != null ? enteredApptNum : "" %>" placeholder="e.g. APPT-1001 or APT-76201" required style="flex: 1;">
                                <button type="submit" class="btn btn-primary">Search Appointment</button>
                            </div>
                            <% if (searchSuccess != null) { %>
                                <small style="display: block; margin-top: 6px; font-size: 0.85rem; font-weight: 500; color: #4ade80;"><%= searchSuccess %></small>
                            <% } else if (searchError != null) { %>
                                <small style="display: block; margin-top: 6px; font-size: 0.85rem; font-weight: 500; color: #f87171;"><%= searchError %></small>
                            <% } %>
                        </div>
                    </form>

                    <!-- Search Result Card -->
                    <% if (searchedAppointment != null) { %>
                        <div style="background: #ffffff; border: 2px solid #0284c7; padding: 1.75rem; border-radius: 16px; margin-bottom: 2rem; box-shadow: 0 10px 25px -5px rgba(2, 132, 199, 0.12);">
                            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 1rem; margin-bottom: 1.25rem;">
                                <div>
                                    <h3 style="margin: 0; font-size: 1.35rem; color: #0f172a; font-weight: 700;">Appointment Details (<%= searchedAppointment.getAppointmentNumber() %>)</h3>
                                    <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.85rem;">Complete Patient & Schedule Record</p>
                                </div>
                                <span class="status-pill status-<%= searchedAppointment.getStatus().toLowerCase() %>" style="font-size: 0.95rem; padding: 6px 14px;"><%= searchedAppointment.getStatus() %></span>
                            </div>

                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.25rem; background: #f8fafc; padding: 1.25rem; border-radius: 12px; border: 1px solid #e2e8f0;">
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">PATIENT NAME</strong>
                                    <span style="font-weight: 700; font-size: 1.1rem; color: #0f172a;"><%= searchedAppointment.getPatientName() %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">CONTACT PHONE</strong>
                                    <span style="font-weight: 700; font-size: 1.1rem; color: #0f172a;"><%= searchedAppointment.getContactNumber() %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">RESIDENTIAL ADDRESS</strong>
                                    <span style="font-weight: 600; color: #334155;"><%= searchedAppointment.getAddress() != null ? searchedAppointment.getAddress() : "-" %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">CONSULTING DENTIST</strong>
                                    <span style="font-weight: 700; font-size: 1.05rem; color: #0284c7;"><%= searchedAppointment.getDentistName() %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">TREATMENT SERVICE</strong>
                                    <span style="font-weight: 700; font-size: 1.05rem; color: #059669;"><%= searchedAppointment.getTreatmentName() %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">SERVICE COST</strong>
                                    <span style="font-weight: 800; font-size: 1.05rem; color: #d97706;">LKR <%= String.format("%,.2f", searchedAppointment.getTreatmentCost()) %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">SCHEDULED DATE & TIME</strong>
                                    <span style="font-weight: 700; color: #0f172a;"><%= searchedAppointment.getAppointmentDate() %> @ <%= searchedAppointment.getAppointmentTime() %></span>
                                </div>
                            </div>

                            <div style="margin-top: 1.5rem; border-top: 1px solid #e2e8f0; padding-top: 1.25rem; display: flex; gap: 12px; flex-wrap: wrap;">
                                <button type="button" onclick="toggleApptUpdateForm()" class="btn btn-primary" style="padding: 10px 20px; font-weight: 700;">✏️ Update Appointment</button>
                                <% if (!"Cancelled".equals(searchedAppointment.getStatus())) { %>
                                    <a href="appointments?action=updateStatus&appointment_number=<%= searchedAppointment.getAppointmentNumber() %>&status=Cancelled" class="btn btn-danger" style="padding: 10px 20px; font-weight: 700;" onclick="return confirm('Cancel appointment <%= searchedAppointment.getAppointmentNumber() %>?')">Cancel Appointment</a>
                                <% } %>
                            </div>

                            <!-- Inline Update Appointment Form -->
                            <form id="appt-update-form" action="appointments" method="POST" style="display: none; margin-top: 1.5rem; background: rgba(0, 0, 0, 0.35); padding: 1.5rem; border-radius: 12px; border: 1px solid #38bdf8;">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="appointment_number" value="<%= searchedAppointment.getAppointmentNumber() %>">
                                <h4 style="margin: 0 0 1rem 0; color: #38bdf8; font-size: 1.1rem;">Update Appointment Schedule & Details</h4>
                                
                                <div class="form-grid">
                                    <div class="form-group">
                                        <label for="update_dentist_name">Dentist Name</label>
                                        <select id="update_dentist_name" name="dentist_name" required>
                                            <% if (dentists != null) { for (Dentist d : dentists) { %>
                                                <option value="<%= d.getDentistName() %>" <%= d.getDentistName().equals(searchedAppointment.getDentistName()) ? "selected" : "" %>><%= d.getDentistName() %> (<%= d.getSpecialization() %>)</option>
                                            <% } } %>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <label for="update_treatment_id">Treatment Service</label>
                                        <select id="update_treatment_id" name="treatment_id" required>
                                            <% if (treatments != null) { for (Treatment t : treatments) { %>
                                                <option value="<%= t.getId() %>" <%= t.getId() == searchedAppointment.getTreatmentId() ? "selected" : "" %>><%= t.getTreatmentName() %> - LKR <%= String.format("%,.2f", t.getCost()) %></option>
                                            <% } } %>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <label for="update_appointment_date">Appointment Date</label>
                                        <input type="date" id="update_appointment_date" name="appointment_date" value="<%= searchedAppointment.getAppointmentDate() %>" required>
                                    </div>

                                    <div class="form-group">
                                        <label for="update_appointment_time">Appointment Time</label>
                                        <input type="time" id="update_appointment_time" name="appointment_time" value="<%= searchedAppointment.getAppointmentTime() %>" required>
                                    </div>

                                    <div class="form-group full-width">
                                        <label for="update_status">Appointment Status</label>
                                        <select id="update_status" name="status" required>
                                            <option value="Scheduled" <%= "Scheduled".equals(searchedAppointment.getStatus()) ? "selected" : "" %>>Scheduled</option>
                                            <option value="Completed" <%= "Completed".equals(searchedAppointment.getStatus()) ? "selected" : "" %>>Completed</option>
                                            <option value="Cancelled" <%= "Cancelled".equals(searchedAppointment.getStatus()) ? "selected" : "" %>>Cancelled</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-actions" style="margin-top: 1.25rem;">
                                    <button type="button" class="btn btn-secondary" onclick="toggleApptUpdateForm()">Cancel</button>
                                    <button type="submit" class="btn btn-primary">Save Updated Appointment</button>
                                </div>
                            </form>
                        </div>
                    <% } %>

                </div> <!-- End Search Form Card Panel -->

                <!-- Separate Panel Card for Appointments Table -->
                <div class="panel" style="margin-top: 1.75rem;">
                    <div class="panel-header">
                        <h2 class="panel-title">Appointments Directory & Schedules</h2>
                        <p class="panel-subtitle">View all registered patient appointments, current status, and actions</p>
                    </div>
                    <div style="overflow-x: auto; border-radius: 12px; border: 1px solid #e2e8f0;">
                        <table class="report-table" style="margin-top: 0;">
                            <thead>
                                <tr>
                                    <th>Appt #</th>
                                    <th>Patient Name</th>
                                    <th>Contact</th>
                                    <th>Dentist</th>
                                    <th>Date & Time</th>
                                    <th>Status</th>
                                    <th style="text-align: right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (appointments != null && !appointments.isEmpty()) { for (Appointment a : appointments) {
                                    boolean isSelected = (searchedAppointment != null && a.getAppointmentNumber().equals(searchedAppointment.getAppointmentNumber()));
                                %>
                                    <tr class="<%= isSelected ? "highlight-row" : "" %>">
                                        <td><strong><%= a.getAppointmentNumber() %></strong></td>
                                        <td><%= a.getPatientName() %></td>
                                        <td><%= a.getContactNumber() %></td>
                                        <td><%= a.getDentistName() %></td>
                                        <td><%= a.getAppointmentDate() %> @ <%= a.getAppointmentTime() %></td>
                                        <td><span class="status-pill status-<%= a.getStatus().toLowerCase() %>"><%= a.getStatus() %></span></td>
                                        <td style="text-align: right;">
                                            <a href="dashboard?tab=tab-search&search_appt_num=<%= a.getAppointmentNumber() %>" class="btn btn-secondary" style="padding: 4px 10px; font-size: 0.8rem; margin-right: 4px;">Update</a>
                                            <% if (!"Cancelled".equals(a.getStatus())) { %>
                                                <a href="appointments?action=updateStatus&appointment_number=<%= a.getAppointmentNumber() %>&status=Cancelled" class="btn btn-danger" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Cancel appointment <%= a.getAppointmentNumber() %>?')">Cancel</a>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="7" style="text-align: center; color: #64748b;">No appointments found.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- TAB 4: CALCULATE & BILL -->
            <section id="tab-billing" class="tab-content <%= "tab-billing".equals(activeTab) ? "active" : "" %>">
                <div class="panel">
                    <div class="panel-header">
                        <h2 class="panel-title">Calculate & Print Bill</h2>
                        <p class="panel-subtitle">Select a patient appointment to view details, add consultation fee, and issue payment receipt</p>
                    </div>

                    <!-- Search Form by Appointment Number -->
                    <form action="dashboard" method="GET" style="margin-bottom: 2rem;">
                        <input type="hidden" name="tab" value="tab-billing">
                        <div class="form-group full-width">
                            <label for="bill_appt_num">Lookup Appointment for Billing <span style="font-weight: normal; font-size: 0.8rem; color: #38bdf8;">(Enter Appointment # e.g. APPT-1001 or select from directory table below)</span></label>
                            <div style="display: flex; gap: 10px;">
                                <input type="text" id="bill_appt_num" name="bill_appt_num" value="<%= enteredBillApptNum != null ? enteredBillApptNum : "" %>" placeholder="e.g. APPT-1001" required style="flex: 1;">
                                <button type="submit" class="btn btn-primary">Lookup Appointment</button>
                            </div>
                            <% if (billApptError != null) { %>
                                <small style="display: block; margin-top: 6px; font-size: 0.85rem; font-weight: 500; color: #f87171;"><%= billApptError %></small>
                            <% } %>
                        </div>
                    </form>

                    <!-- Selected Appointment Details & Fee Form Card -->
                    <% if (selectedBillAppt != null) {
                        boolean isPaid = "Paid".equalsIgnoreCase(selectedBillAppt.getPaymentStatus());
                    %>
                        <div style="background: #ffffff; border: 2px solid #0284c7; padding: 1.75rem; border-radius: 16px; margin-bottom: 2rem; box-shadow: 0 10px 25px -5px rgba(2, 132, 199, 0.12);">
                            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 1rem; margin-bottom: 1.25rem;">
                                <div>
                                    <h3 style="margin: 0; font-size: 1.35rem; color: #0f172a; font-weight: 700;">Appointment Billing Details (<%= selectedBillAppt.getAppointmentNumber() %>)</h3>
                                    <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.85rem;">Patient details & Consultation Fee calculator</p>
                                </div>
                                <div>
                                    <% if (isPaid) { %>
                                        <span class="status-pill status-paid" style="font-size: 0.9rem; padding: 6px 16px;">✓ Paid</span>
                                    <% } else { %>
                                        <span class="status-pill status-unpaid" style="font-size: 0.9rem; padding: 6px 16px;">⚠️ Unpaid</span>
                                    <% } %>
                                </div>
                            </div>

                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.25rem; background: #f8fafc; padding: 1.25rem; border-radius: 12px; border: 1px solid #e2e8f0; margin-bottom: 1.5rem;">
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">PATIENT NAME</strong>
                                    <span style="font-weight: 700; font-size: 1.1rem; color: #0f172a;"><%= selectedBillAppt.getPatientName() %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">CONTACT PHONE</strong>
                                    <span style="font-weight: 700; font-size: 1.1rem; color: #0f172a;"><%= selectedBillAppt.getContactNumber() %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">RESIDENTIAL ADDRESS</strong>
                                    <span style="font-weight: 600; color: #334155;"><%= selectedBillAppt.getAddress() != null ? selectedBillAppt.getAddress() : "-" %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">CONSULTING DENTIST</strong>
                                    <span style="font-weight: 700; font-size: 1.05rem; color: #0284c7;"><%= selectedBillAppt.getDentistName() %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">TREATMENT SERVICE</strong>
                                    <span style="font-weight: 700; font-size: 1.05rem; color: #059669;"><%= selectedBillAppt.getTreatmentName() %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">TREATMENT PACKAGE PRICE</strong>
                                    <span style="font-weight: 800; font-size: 1.05rem; color: #d97706;">LKR <%= String.format("%,.2f", selectedBillAppt.getTreatmentCost()) %></span>
                                </div>
                                <div>
                                    <strong style="color: #64748b; font-size: 0.75rem; font-weight: 700; display: block; letter-spacing: 0.5px;">SCHEDULED DATE & TIME</strong>
                                    <span style="font-weight: 700; color: #0f172a;"><%= selectedBillAppt.getAppointmentDate() %> @ <%= selectedBillAppt.getAppointmentTime() %></span>
                                </div>
                            </div>

                            <!-- Payment Entry Form -->
                            <form action="bills" method="POST" style="border-top: 1px solid #e2e8f0; padding-top: 1.25rem; margin-top: 1rem;">
                                <input type="hidden" name="appointment_number" value="<%= selectedBillAppt.getAppointmentNumber() %>">
                                <input type="hidden" id="treatment_cost_val" value="<%= selectedBillAppt.getTreatmentCost() %>">
                                <input type="hidden" id="balance_returned" name="balance_returned" value="0.00">

                                <div class="form-grid">
                                    <div class="form-group full-width">
                                        <label for="consultation_fee" style="color: #0f172a; font-weight: 700;">Doctor Consultation Fee (LKR) <span style="color: #ef4444;">*</span></label>
                                        <input type="number" step="0.01" id="consultation_fee" name="consultation_fee" placeholder="Enter doctor consultation fee (e.g. 1500.00)" required autofocus oninput="calculateCashBalance()" style="font-size: 1.1rem; padding: 12px; background: #ffffff; border: 1.5px solid #cbd5e1; color: #0f172a; font-weight: 600;">
                                    </div>

                                    <div class="form-group full-width">
                                        <label style="display: block; margin-bottom: 8px; color: #0f172a; font-weight: 700;">Select Payment Method <span style="color: #ef4444;">*</span></label>
                                        <div style="display: flex; gap: 20px; background: #f8fafc; padding: 12px 16px; border-radius: 8px; border: 1.5px solid #cbd5e1;">
                                            <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 700; color: #0284c7;">
                                                <input type="radio" id="method-cash" name="payment_method" value="Cash" checked onclick="switchPaymentMethod('Cash')">
                                                💵 Cash Payment
                                            </label>
                                            <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 700; color: #7c3aed;">
                                                <input type="radio" id="method-card" name="payment_method" value="Card" onclick="switchPaymentMethod('Card')">
                                                💳 Credit / Debit Card
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <!-- Total Bill Summary Box -->
                                <div style="background: #e0f2fe; border: 1.5px solid #bae6fd; padding: 1rem 1.25rem; border-radius: 10px; margin-top: 1rem; display: flex; justify-content: space-between; align-items: center;">
                                    <div>
                                        <span style="color: #0369a1; font-size: 0.8rem; font-weight: 700; text-transform: uppercase; display: block;">ESTIMATED TOTAL BILL (Treatment + Consultation)</span>
                                        <span style="font-size: 1.5rem; font-weight: 800; color: #0284c7;">LKR <span id="calc_total_cost"><%= String.format("%,.2f", selectedBillAppt.getTreatmentCost()) %></span></span>
                                    </div>
                                </div>

                                <!-- CASH PAYMENT SECTION -->
                                <div id="cash-payment-section" style="margin-top: 1.25rem; background: #f8fafc; padding: 1.25rem; border-radius: 12px; border: 1.5px solid #cbd5e1;">
                                    <h4 style="margin: 0 0 1rem 0; color: #0284c7; font-weight: 700;">💵 Cash Payment & Balance Calculator</h4>
                                    <div class="form-grid">
                                        <div class="form-group">
                                            <label for="cash_given" style="color: #0f172a; font-weight: 700;">Cash Given by Patient (LKR) <span style="color: #ef4444;">*</span></label>
                                            <input type="number" step="0.01" id="cash_given" name="cash_given" placeholder="e.g. 10000.00" oninput="calculateCashBalance()" style="font-size: 1.05rem; background: #ffffff; border: 1.5px solid #cbd5e1; color: #0f172a; font-weight: 600;">
                                        </div>

                                        <div class="form-group">
                                            <label style="color: #0f172a; font-weight: 700;">Balance Change to Return to Patient</label>
                                            <div style="background: #ffffff; padding: 10px 14px; border-radius: 8px; border: 1.5px solid #cbd5e1; font-size: 1.2rem; font-weight: 800;">
                                                <span id="calc_balance" style="color: #16a34a;">LKR 0.00</span>
                                            </div>
                                        </div>
                                    </div>
                                    <small id="cash_error_msg" style="display: none; color: #dc2626; font-weight: 700; margin-top: 6px;"></small>
                                </div>

                                <!-- CARD PAYMENT SECTION -->
                                <div id="card-payment-section" style="display: none; margin-top: 1.25rem; background: #f8fafc; padding: 1.25rem; border-radius: 12px; border: 1.5px solid #cbd5e1;">
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                                        <h4 style="margin: 0; color: #7c3aed; font-weight: 700;">💳 Credit / Debit Card Processing</h4>
                                        <span style="font-size: 0.75rem; background: #f1f5f9; border: 1px solid #cbd5e1; padding: 4px 10px; border-radius: 12px; color: #475569; font-weight: 600;">🔒 Card details are client-processed and NOT saved in database</span>
                                    </div>
                                    
                                    <div class="form-grid">
                                        <div class="form-group full-width">
                                            <label style="color: #0f172a; font-weight: 700;">Cardholder Name</label>
                                            <input type="text" placeholder="Name on card e.g. M N PERERA" style="font-size: 1rem; background: #ffffff; border: 1.5px solid #cbd5e1; color: #0f172a;">
                                        </div>

                                        <div class="form-group">
                                            <label style="color: #0f172a; font-weight: 700;">Card Number</label>
                                            <input type="text" placeholder="1234 5678 9101 1121" maxlength="19" oninput="formatCardNumber(this)" style="font-size: 1rem; font-family: monospace; background: #ffffff; border: 1.5px solid #cbd5e1; color: #0f172a;">
                                        </div>

                                        <div class="form-group">
                                            <label style="color: #0f172a; font-weight: 700;">Expiration Date (MM/YY)</label>
                                            <input type="text" placeholder="MM/YY" maxlength="5" oninput="formatCardExpiry(this)" style="font-size: 1rem; font-family: monospace; background: #ffffff; border: 1.5px solid #cbd5e1; color: #0f172a;">
                                        </div>

                                        <div class="form-group">
                                            <label style="color: #0f172a; font-weight: 700;">CVV / CVC Code</label>
                                            <input type="password" placeholder="123" maxlength="4" style="font-size: 1rem; font-family: monospace; background: #ffffff; border: 1.5px solid #cbd5e1; color: #0f172a;">
                                        </div>
                                    </div>
                                </div>

                                <div class="form-actions" style="margin-top: 1.5rem; display: flex; gap: 10px; flex-wrap: wrap;">
                                    <button type="submit" id="btn-submit-payment" class="btn btn-primary" style="background: #16a34a; border-color: #16a34a; font-weight: 700; font-size: 1rem; padding: 10px 20px;">💳 Generate Payment Receipt & Mark as Paid</button>
                                    <a href="dashboard?tab=tab-billing" class="btn btn-secondary" style="font-weight: 600;">Select Another Patient</a>
                                </div>
                            </form>
                        </div>
                    <% } %>

                </div> <!-- End Billing Calculator Card Panel -->

                <!-- Separate Panel Card for Appointments Billing Directory Table -->
                <div class="panel" style="margin-top: 1.75rem;">
                    <div class="panel-header">
                        <h2 class="panel-title">Appointments Billing Directory</h2>
                        <p class="panel-subtitle">Select an appointment from the table below to process payment or view bill details</p>
                    </div>
                    <div style="overflow-x: auto; border-radius: 12px; border: 1px solid #e2e8f0;">
                        <table class="report-table" style="margin-top: 0;">
                            <thead>
                                <tr>
                                    <th>Appt #</th>
                                    <th>Patient Name</th>
                                    <th>Contact</th>
                                    <th>Dentist</th>
                                    <th>Treatment</th>
                                    <th>Price</th>
                                    <th>Payment Status</th>
                                    <th style="text-align: right;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (appointments != null && !appointments.isEmpty()) { for (Appointment a : appointments) {
                                    boolean isSel = (selectedBillAppt != null && a.getAppointmentNumber().equals(selectedBillAppt.getAppointmentNumber()));
                                    boolean aPaid = "Paid".equalsIgnoreCase(a.getPaymentStatus());
                                %>
                                    <tr class="<%= isSel ? "highlight-row" : "" %>">
                                        <td><strong><%= a.getAppointmentNumber() %></strong></td>
                                        <td style="font-weight: 600;"><%= a.getPatientName() %></td>
                                        <td><%= a.getContactNumber() %></td>
                                        <td><%= a.getDentistName() %></td>
                                        <td><%= a.getTreatmentName() %></td>
                                        <td>LKR <%= String.format("%,.2f", a.getTreatmentCost()) %></td>
                                        <td>
                                            <% if (aPaid) { %>
                                                <span class="status-pill status-paid">✓ Paid</span>
                                            <% } else { %>
                                                <span class="status-pill status-unpaid">⚠️ Unpaid</span>
                                            <% } %>
                                        </td>
                                        <td style="text-align: right;">
                                            <a href="dashboard?tab=tab-billing&bill_appt_num=<%= a.getAppointmentNumber() %>" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">Calculate & Bill</a>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="8" style="text-align: center; color: #64748b;">No appointments found.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <% if ("Admin".equals(role)) { %>
            <!-- TAB: USER MANAGEMENT (ADMIN ONLY) -->
            <section id="tab-users" class="tab-content <%= "tab-users".equals(activeTab) ? "active" : "" %>">
                <div class="panel">
                    <div class="panel-header">
                        <h2 class="panel-title">User Account Management</h2>
                        <p class="panel-subtitle">Manage system staff and administrator accounts</p>
                    </div>

                    <form action="users" method="POST">
                        <input type="hidden" id="user-id" name="id" value="0">
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="user-username">Username</label>
                                <input type="text" id="user-username" name="username" placeholder="e.g. john_staff" required minlength="3">
                            </div>

                            <div class="form-group">
                                <label for="user-fullname">Full Name</label>
                                <input type="text" id="user-fullname" name="full_name" placeholder="e.g. Johnathan Doe" required>
                            </div>

                            <div class="form-group">
                                <label for="user-role">System Role</label>
                                <select id="user-role" name="role" required>
                                    <option value="Staff" selected>Staff Member</option>
                                    <option value="Admin">Administrator</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="user-password">Password</label>
                                <input type="password" id="user-password" name="password" placeholder="••••••••">
                            </div>

                            <div class="form-group">
                                <label for="user-confirm-password">Confirm Password</label>
                                <input type="password" id="user-confirm-password" name="confirm_password" placeholder="••••••••">
                            </div>
                        </div>

                        <div class="form-actions" style="margin-top: 1.5rem;">
                            <button type="button" class="btn btn-secondary" onclick="resetUserForm()">Clear Form</button>
                            <button type="submit" class="btn btn-primary">Save User Account</button>
                        </div>
                    </form>

                </div> <!-- End User Form Card Panel -->

                <!-- Separate Panel Card for System Users Table -->
                <div class="panel" style="margin-top: 1.75rem;">
                    <div class="panel-header">
                        <h2 class="panel-title">System Users Directory</h2>
                        <p class="panel-subtitle">Registered system administrator and clinical staff user accounts</p>
                    </div>
                    <div style="overflow-x: auto; border-radius: 12px; border: 1px solid #e2e8f0;">
                        <table class="report-table" style="margin-top: 0;">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Username</th>
                                    <th>Full Name</th>
                                    <th>Role</th>
                                    <th style="text-align: right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (users != null && !users.isEmpty()) { for (User u : users) { %>
                                    <tr>
                                        <td><%= u.getId() %></td>
                                        <td style="font-weight: 600;"><%= u.getUsername() %></td>
                                        <td><%= u.getFullName() %></td>
                                        <td><span class="status-pill status-scheduled"><%= u.getRole() %></span></td>
                                        <td style="text-align: right;">
                                            <button type="button" class="btn btn-secondary" style="padding: 4px 10px; font-size: 0.8rem; margin-right: 4px;" data-id="<%= u.getId() %>" data-username="<%= u.getUsername() %>" data-fullname="<%= u.getFullName() %>" data-role="<%= u.getRole() %>" onclick="handleEditUser(this)">Edit</button>
                                            <a href="users?action=delete&id=<%= u.getId() %>" class="btn btn-danger" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Delete user <%= u.getUsername() %>?')">Delete</a>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="5" style="text-align: center; color: #64748b;">No users found.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- TAB: DENTIST MANAGEMENT (ADMIN ONLY) -->
            <section id="tab-dentists" class="tab-content <%= "tab-dentists".equals(activeTab) ? "active" : "" %>">
                <div class="panel">
                    <div class="panel-header">
                        <h2 class="panel-title">Dentist Profile Management</h2>
                        <p class="panel-subtitle">Register, update, or remove consulting dentists and specializations</p>
                    </div>

                    <form action="dentists" method="POST">
                        <input type="hidden" id="dentist-id" name="id" value="0">
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="dentist-name-input">Dentist Name</label>
                                <input type="text" id="dentist-name-input" name="dentist_name" placeholder="e.g. Dr. Kasun Perera" required minlength="3">
                            </div>

                            <div class="form-group">
                                <label for="dentist-specialization">Specialization</label>
                                <select id="dentist-specialization" name="specialization" required>
                                    <option value="" disabled selected>Select Specialization</option>
                                    <option value="General Dentist">General Dentist</option>
                                    <option value="Orthodontist">Orthodontist</option>
                                    <option value="Pediatric Dentist">Pediatric Dentist (Pedodontist)</option>
                                    <option value="Periodontist">Periodontist</option>
                                    <option value="Endodontist">Endodontist</option>
                                    <option value="Oral & Maxillofacial Surgeon">Oral & Maxillofacial Surgeon</option>
                                    <option value="Prosthodontist">Prosthodontist</option>
                                    <option value="Cosmetic Dentist">Cosmetic Dentist</option>
                                </select>
                            </div>

                            <div class="form-group full-width">
                                <label for="dentist-contact">Contact Phone Number</label>
                                <input type="tel" id="dentist-contact" name="contact_number" placeholder="e.g. 0771234567">
                            </div>
                        </div>

                        <div class="form-actions" style="margin-top: 1.5rem;">
                            <button type="button" class="btn btn-secondary" onclick="resetDentistForm()">Clear Form</button>
                            <button type="submit" class="btn btn-primary">Save Dentist Profile</button>
                        </div>
                    </form>

                </div> <!-- End Dentist Form Card Panel -->

                <!-- Separate Panel Card for Registered Dentists Table -->
                <div class="panel" style="margin-top: 1.75rem;">
                    <div class="panel-header">
                        <h2 class="panel-title">Registered Dentists Directory</h2>
                        <p class="panel-subtitle">List of consulting dentists, specializations, and contact phone numbers</p>
                    </div>
                    <div style="overflow-x: auto; border-radius: 12px; border: 1px solid #e2e8f0;">
                        <table class="report-table" style="margin-top: 0;">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Dentist Name</th>
                                    <th>Specialization</th>
                                    <th>Contact Number</th>
                                    <th style="text-align: right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (dentists != null && !dentists.isEmpty()) { for (Dentist d : dentists) { %>
                                    <tr>
                                        <td><%= d.getId() %></td>
                                        <td style="font-weight: 600;"><%= d.getDentistName() %></td>
                                        <td><%= d.getSpecialization() %></td>
                                        <td><%= d.getContactNumber() != null ? d.getContactNumber() : "-" %></td>
                                        <td style="text-align: right;">
                                            <button type="button" class="btn btn-secondary" style="padding: 4px 10px; font-size: 0.8rem; margin-right: 4px;" data-id="<%= d.getId() %>" data-name="<%= d.getDentistName() %>" data-spec="<%= d.getSpecialization() %>" data-contact="<%= d.getContactNumber() != null ? d.getContactNumber() : "" %>" onclick="handleEditDentist(this)">Edit</button>
                                            <a href="dentists?action=delete&id=<%= d.getId() %>" class="btn btn-danger" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Delete dentist <%= d.getDentistName() %>?')">Delete</a>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="5" style="text-align: center; color: #64748b;">No dentist records found.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- TAB: TREATMENT SERVICE MANAGEMENT (ADMIN ONLY) -->
            <section id="tab-treatments" class="tab-content <%= "tab-treatments".equals(activeTab) ? "active" : "" %>">
                <div class="panel">
                    <div class="panel-header">
                        <h2 class="panel-title">Treatment Service Packages & Pricing</h2>
                        <p class="panel-subtitle">Create, update service rates, or remove clinical treatment packages</p>
                    </div>

                    <form action="treatments" method="POST">
                        <input type="hidden" id="treatment-id-input" name="id" value="0">
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="treatment-name-input">Treatment Service Name</label>
                                <select id="treatment-name-input" name="treatment_name" required>
                                    <option value="" disabled selected>Select Treatment Service</option>
                                    <option value="Dental Cleaning & Scaling">Dental Cleaning & Scaling</option>
                                    <option value="Composite Filling">Composite Filling</option>
                                    <option value="Tooth Extraction">Tooth Extraction</option>
                                    <option value="Root Canal Therapy">Root Canal Therapy</option>
                                    <option value="Teeth Whitening">Teeth Whitening</option>
                                    <option value="Braces Consultation">Braces Consultation</option>
                                    <option value="Dental Crown & Bridge">Dental Crown & Bridge</option>
                                    <option value="Dental Implant Consultation">Dental Implant Consultation</option>
                                    <option value="Fluoride Treatment">Fluoride Treatment</option>
                                    <option value="Wisdom Tooth Surgery">Wisdom Tooth Surgery</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="treatment-cost-input">Service Price / Cost (LKR)</label>
                                <input type="number" step="0.01" id="treatment-cost-input" name="cost" placeholder="e.g. 5000.00" required min="0">
                            </div>
                        </div>

                        <div class="form-actions" style="margin-top: 1.5rem;">
                            <button type="button" class="btn btn-secondary" onclick="resetTreatmentForm()">Clear Form</button>
                            <button type="submit" class="btn btn-primary">Save Treatment Service</button>
                        </div>
                    </form>

                </div> <!-- End Treatment Form Card Panel -->

                <!-- Separate Panel Card for Service Rates Table -->
                <div class="panel" style="margin-top: 1.75rem;">
                    <div class="panel-header">
                        <h2 class="panel-title">Clinic Treatment Packages & Service Rates</h2>
                        <p class="panel-subtitle">Active clinical treatment packages and current price rates</p>
                    </div>
                    <div style="overflow-x: auto; border-radius: 12px; border: 1px solid #e2e8f0;">
                        <table class="report-table" style="margin-top: 0;">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Treatment Service Name</th>
                                    <th style="text-align: right;">Service Cost (LKR)</th>
                                    <th style="text-align: right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (treatments != null && !treatments.isEmpty()) { for (Treatment t : treatments) { %>
                                    <tr>
                                        <td><%= t.getId() %></td>
                                        <td style="font-weight: 600;"><%= t.getTreatmentName() %></td>
                                        <td style="text-align: right;">LKR <%= String.format("%,.2f", t.getCost()) %></td>
                                        <td style="text-align: right;">
                                            <button type="button" class="btn btn-secondary" style="padding: 4px 10px; font-size: 0.8rem; margin-right: 4px;" data-id="<%= t.getId() %>" data-name="<%= t.getTreatmentName() %>" data-cost="<%= t.getCost() %>" onclick="handleEditTreatment(this)">Edit</button>
                                            <a href="treatments?action=delete&id=<%= t.getId() %>" class="btn btn-danger" style="padding: 4px 10px; font-size: 0.8rem;" onclick="return confirm('Delete treatment <%= t.getTreatmentName() %>?')">Delete</a>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="4" style="text-align: center; color: #64748b;">No treatment packages found.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
            <% } %>

            <!-- TAB: HELP & SYSTEM GUIDANCE SECTION -->
            <section id="tab-help" class="tab-content <%= "tab-help".equals(activeTab) ? "active" : "" %>">
                <div class="panel">
                    <div class="panel-header">
                        <h2 class="panel-title">Help Section & System Guidance</h2>
                        <p class="panel-subtitle">Comprehensive user guides, workflows, and FAQs for staff and administrators</p>
                    </div>

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin-bottom: 2rem;">
                        <div style="background: #ffffff; border: 1px solid #e2e8f0; padding: 1.5rem; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03);">
                            <h3 style="color: #0284c7; margin-bottom: 0.75rem; font-size: 1.1rem; font-weight: 700;">📅 Registering Appointments</h3>
                            <p style="font-size: 0.92rem; color: #334155; line-height: 1.6;">
                                1. Enter the patient's NIC or Passport number and click <strong style="color: #0f172a;">Verify Patient</strong>.<br>
                                2. If registered, the patient's details will auto-populate.<br>
                                3. Select Dentist, Treatment Package, Date, and Time, then click <strong style="color: #0284c7;">Register Appointment</strong>.
                            </p>
                        </div>

                        <div style="background: #ffffff; border: 1px solid #e2e8f0; padding: 1.5rem; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03);">
                            <h3 style="color: #059669; margin-bottom: 0.75rem; font-size: 1.1rem; font-weight: 700;">👤 Patient Registration</h3>
                            <p style="font-size: 0.92rem; color: #334155; line-height: 1.6;">
                                1. Clinic staff or admins can add new patient profiles under <strong style="color: #0f172a;">Patient Registration</strong>.<br>
                                2. Patient Name, NIC/Passport, and Contact Phone are required.<br>
                                3. Existing profiles can be updated or deleted using table action buttons.
                            </p>
                        </div>

                        <div style="background: #ffffff; border: 1px solid #e2e8f0; padding: 1.5rem; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03);">
                            <h3 style="color: #d97706; margin-bottom: 0.75rem; font-size: 1.1rem; font-weight: 700;">🧾 Billing & Receipts</h3>
                            <p style="font-size: 0.92rem; color: #334155; line-height: 1.6;">
                                1. Go to <strong style="color: #0f172a;">Calculate & Bill</strong> tab.<br>
                                2. Enter the Appointment Number (e.g. <code style="background: #f1f5f9; padding: 2px 6px; border-radius: 4px; color: #0f172a;">APPT-1001</code>) and Doctor Consultation Fee.<br>
                                3. Click <strong style="color: #d97706;">Generate Payment Receipt</strong> to view and print the official receipt.
                            </p>
                        </div>

                        <% if ("Admin".equals(role)) { %>
                        <div style="background: #ffffff; border: 1px solid #e2e8f0; padding: 1.5rem; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.03);">
                            <h3 style="color: #9333ea; margin-bottom: 0.75rem; font-size: 1.1rem; font-weight: 700;">⚙️ Admin Controls</h3>
                            <p style="font-size: 0.92rem; color: #334155; line-height: 1.6;">
                                • <strong style="color: #0f172a;">User Management</strong>: Create, edit, or delete staff and admin user accounts.<br>
                                • <strong style="color: #0f172a;">Dentist Management</strong>: Register consulting doctors and specializations.<br>
                                • <strong style="color: #0f172a;">Treatment Packages</strong>: Manage clinic treatment offerings and pricing.
                            </p>
                        </div>
                        <% } %>
                    </div>

                    <div style="background: #f8fafc; border: 1px solid #e2e8f0; padding: 1.75rem; border-radius: 16px;">
                        <h3 style="color: #0284c7; margin-bottom: 1rem; font-size: 1.2rem; font-weight: 700;">❓ Frequently Asked Questions (FAQ)</h3>
                        <div style="display: flex; flex-direction: column; gap: 1.25rem; font-size: 0.92rem;">
                            <div style="border-bottom: 1px solid #e2e8f0; padding-bottom: 1rem;">
                                <strong style="color: #0f172a; font-size: 0.95rem; display: block; margin-bottom: 0.25rem;">Q: Can unregistered patients book appointments?</strong>
                                <p style="color: #475569; margin: 0;">A: No. Patients must first be registered under Patient Registration using a valid NIC or Passport number.</p>
                            </div>
                            <div>
                                <strong style="color: #0f172a; font-size: 0.95rem; display: block; margin-bottom: 0.25rem;">Q: How do I change an appointment status to Completed or Cancelled?</strong>
                                <p style="color: #475569; margin: 0;">A: Navigate to <strong>Search Details</strong> directory and click the <em>Complete</em> or <em>Cancel</em> action button next to the schedule.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

        </main>
    </div>

    <!-- Floating Back to Top Scroll Button -->
    <button id="btn-scroll-top" onclick="window.scrollTo({top: 0, behavior: 'smooth'});" title="Scroll to top" style="position: fixed; bottom: 30px; right: 30px; background: linear-gradient(135deg, #0284c7, #06b6d4); color: #ffffff; border: none; width: 48px; height: 48px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; cursor: pointer; box-shadow: 0 10px 25px rgba(2, 132, 199, 0.4); transition: all 0.3s ease; z-index: 9999;">
        ⬆
    </button>

    <script src="js/app.js?v=9"></script>
</body>
</html>
