<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.model.User" %>
<%@ page import="com.sunrisedental.dao.*" %>
<%@ page import="com.sunrisedental.dao.impl.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String role = sessionUser.getRole();

    String filterDate = request.getParameter("filter_date");
    String filterMonth = request.getParameter("filter_month");

    AppointmentDAO appointmentDAO = new AppointmentDAOImpl();
    BillDAO billDAO = new BillDAOImpl();

    Map<String, Integer> apptCounts = appointmentDAO.getAppointmentCounts(filterDate, filterMonth);
    List<Map<String, Object>> dentistStats = appointmentDAO.getDentistStatistics(filterDate, filterMonth);
    Map<String, Object> financialSummary = billDAO.getFinancialSummary(filterDate, filterMonth);
    List<Map<String, Object>> treatmentReport = billDAO.getTreatmentRevenueReport(filterDate, filterMonth);

    String activeFilterLabel = "All Time Record Summary";
    if (filterDate != null && !filterDate.trim().isEmpty()) {
        activeFilterLabel = "Filtered Date: " + filterDate;
    } else if (filterMonth != null && !filterMonth.trim().isEmpty()) {
        activeFilterLabel = "Filtered Month: " + filterMonth;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics & Reports - Sunrise Dental Clinic Management</title>
    <link rel="stylesheet" href="css/style.css?v=9">
    <!-- Chart.js for High Performance Bar Graph & Line Graph Visualizations -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .chart-print-img {
            display: none;
        }

        @media print {
            /* Hide non-printable navigation, sidebar, filter inputs, decor */
            header, header.top-nav, aside, aside.sidebar, .no-print, #btn-scroll-top, .bg-decor {
                display: none !important;
            }

            /* Swap HTML5 Canvas for converted High-Res PNG Image during Print */
            canvas {
                display: none !important;
            }

            .chart-print-img {
                display: block !important;
                width: 100% !important;
                max-height: 240px !important;
                height: auto !important;
                object-fit: contain !important;
                margin: 0 auto !important;
            }

            /* Reset html & body to pure block layout for PDF rendering */
            html, body {
                background: #ffffff !important;
                color: #0f172a !important;
                font-family: 'Outfit', sans-serif, Arial, sans-serif !important;
                width: 100% !important;
                height: auto !important;
                min-height: auto !important;
                margin: 0 !important;
                padding: 0 !important;
                overflow: visible !important;
                display: block !important;
                float: none !important;
                position: static !important;
            }

            /* Container resets for full PDF rendering */
            .main-wrapper, .content-area {
                display: block !important;
                width: 100% !important;
                max-width: 100% !important;
                height: auto !important;
                min-height: auto !important;
                margin: 0 !important;
                padding: 10px !important;
                float: none !important;
                position: static !important;
                overflow: visible !important;
            }

            /* Print Header Banner */
            .print-only-header {
                display: block !important;
                margin-bottom: 15px !important;
                padding-bottom: 10px !important;
                border-bottom: 2px solid #0284c7 !important;
            }

            /* KPI Grid Layout for Print */
            .kpi-grid-container {
                display: grid !important;
                grid-template-columns: repeat(4, 1fr) !important;
                gap: 10px !important;
                margin-bottom: 15px !important;
            }

            .kpi-card-box {
                background: #f8fafc !important;
                border: 1px solid #cbd5e1 !important;
                padding: 10px !important;
                text-align: center !important;
                border-radius: 8px !important;
            }

            /* Panel Card styling for Print */
            .panel {
                background: #ffffff !important;
                color: #0f172a !important;
                border: 1px solid #cbd5e1 !important;
                box-shadow: none !important;
                margin-bottom: 1.25rem !important;
                padding: 1rem !important;
                break-inside: avoid !important;
                page-break-inside: avoid !important;
                display: block !important;
                position: static !important;
                float: none !important;
                width: 100% !important;
            }

            .page-break-before {
                page-break-before: always !important;
                break-before: page !important;
            }

            h1, h2, h3, h4, p, span, td, th, small, strong {
                color: #0f172a !important;
                opacity: 1 !important;
                visibility: visible !important;
            }

            .status-pill {
                border: 1px solid #cbd5e1 !important;
                background: #f1f5f9 !important;
                color: #0f172a !important;
            }

            /* Table formatting for PDF */
            .report-table {
                width: 100% !important;
                border-collapse: collapse !important;
            }

            .report-table th, .report-table td {
                border: 1px solid #cbd5e1 !important;
                padding: 6px 10px !important;
                color: #0f172a !important;
                background: #ffffff !important;
                font-size: 0.85rem !important;
            }
        }
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
            <div class="user-avatar"><%= sessionUser.getFullName().substring(0, 1).toUpperCase() %></div>
            <div class="user-info">
                <span class="user-name"><%= sessionUser.getFullName() %></span>
                <span class="user-role"><%= role %></span>
            </div>
        </div>
    </header>

    <div class="main-wrapper">
        <!-- Sidebar Navigation -->
        <aside class="sidebar">
            <a href="dashboard?tab=tab-register" class="nav-item">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                </svg>
                <span>New Appointment</span>
            </a>
            <a href="dashboard?tab=tab-patients" class="nav-item">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
                <span>Patient Registration</span>
            </a>
            <a href="dashboard?tab=tab-search" class="nav-item">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <span>Search Details</span>
            </a>
            <a href="dashboard?tab=tab-billing" class="nav-item">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                </svg>
                <span>Calculate & Bill</span>
            </a>
            <% if ("Admin".equals(role)) { %>
            <a href="dashboard?tab=tab-users" class="nav-item">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
                <span>User Management</span>
            </a>
            <a href="dashboard?tab=tab-dentists" class="nav-item">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                <span>Dentist Management</span>
            </a>
            <a href="dashboard?tab=tab-treatments" class="nav-item">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L5.605 15.13a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" />
                </svg>
                <span>Treatment Packages</span>
            </a>
            <a href="reports" class="nav-item active">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
                <span>Analytics & Reports</span>
            </a>
            <% } %>

            <a href="dashboard?tab=tab-help" class="nav-item">
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
            <div style="margin-bottom: 2rem; display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem;">
                <div>
                    <h1 style="color: #0284c7; margin-bottom: 0.4rem; font-size: 1.8rem;">Clinic Analytics & Visual Reports</h1>
                    <p style="color: #64748b; font-size: 0.95rem;">Interactive visual charts and financial analysis for clinic performance</p>
                </div>
                <span class="status-pill status-scheduled" style="font-size: 0.9rem; padding: 8px 16px;"><%= activeFilterLabel %></span>
            </div>

            <!-- Print Header Banner (Print Only) -->
            <div class="print-only-header" style="display: none;">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #0284c7; padding-bottom: 10px; margin-bottom: 15px;">
                    <div>
                        <h1 style="color: #0284c7; font-size: 1.5rem; margin: 0; font-weight: 800;">🦷 Sunrise Dental Clinic Management</h1>
                        <p style="color: #64748b; font-size: 0.85rem; margin: 2px 0 0 0;">Official Clinic Performance, Analytics & Financial Report</p>
                    </div>
                    <div style="text-align: right;">
                        <span style="font-weight: 700; color: #0284c7; font-size: 0.9rem;"><%= activeFilterLabel %></span>
                    </div>
                </div>
            </div>

            <!-- Date & Month Filter Card -->
            <div class="panel no-print" style="margin-bottom: 2rem; background: #ffffff;">
                <div class="panel-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                    <div>
                        <h2 class="panel-title" style="color: #0f172a;">📅 Report Date & Month Filter</h2>
                        <p class="panel-subtitle">Select a specific date or month to filter appointment graphs and revenue metrics</p>
                    </div>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <button type="button" onclick="printReport()" class="btn btn-primary">🖨️ Download PDF / Print</button>
                        <button type="button" onclick="downloadCSVReport()" class="btn btn-secondary">📥 Export CSV</button>
                    </div>
                </div>

                <form action="reports" method="GET" style="display: flex; gap: 1.25rem; align-items: flex-end; flex-wrap: wrap;">
                    <div class="form-group" style="flex: 1; min-width: 180px;">
                        <label for="filter_date">Filter by Specific Date</label>
                        <input type="date" id="filter_date" name="filter_date" value="<%= filterDate != null ? filterDate : "" %>" onchange="document.getElementById('filter_month').value=''">
                    </div>

                    <div class="form-group" style="flex: 1; min-width: 180px;">
                        <label for="filter_month">Filter by Specific Month</label>
                        <input type="month" id="filter_month" name="filter_month" value="<%= filterMonth != null ? filterMonth : "" %>" onchange="document.getElementById('filter_date').value=''">
                    </div>

                    <div style="display: flex; gap: 10px;">
                        <button type="submit" class="btn btn-primary">🔍 Filter</button>
                        <a href="reports" class="btn btn-secondary">🔄 Reset</a>
                    </div>
                </form>
            </div>

            <!-- KPI Summary Cards -->
            <div class="kpi-grid-container" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.25rem; margin-bottom: 2rem;">
                <div class="panel kpi-card-box" style="text-align: center; padding: 1.25rem;">
                    <h3 style="color: #64748b; font-size: 0.8rem; font-weight: 700; text-transform: uppercase; margin-bottom: 0.4rem;">Total Appointments</h3>
                    <span style="font-size: 2rem; font-weight: 800; color: #0284c7;"><%= apptCounts.getOrDefault("total", 0) %></span>
                    <small style="display: block; margin-top: 4px; color: #64748b; font-size: 0.75rem;">All Registered Schedules</small>
                </div>

                <div class="panel kpi-card-box" style="text-align: center; padding: 1.25rem;">
                    <h3 style="color: #64748b; font-size: 0.8rem; font-weight: 700; text-transform: uppercase; margin-bottom: 0.4rem;">Completed Appointments</h3>
                    <span style="font-size: 2rem; font-weight: 800; color: #16a34a;"><%= apptCounts.getOrDefault("completed", 0) %></span>
                    <small style="display: block; margin-top: 4px; color: #64748b; font-size: 0.75rem;">Finished Checkups</small>
                </div>

                <div class="panel kpi-card-box" style="text-align: center; padding: 1.25rem;">
                    <h3 style="color: #64748b; font-size: 0.8rem; font-weight: 700; text-transform: uppercase; margin-bottom: 0.4rem;">Cancelled Appointments</h3>
                    <span style="font-size: 2rem; font-weight: 800; color: #dc2626;"><%= apptCounts.getOrDefault("cancelled", 0) %></span>
                    <small style="display: block; margin-top: 4px; color: #64748b; font-size: 0.75rem;">Released Time Slots</small>
                </div>

                <div class="panel kpi-card-box" style="text-align: center; padding: 1.25rem;">
                    <h3 style="color: #64748b; font-size: 0.8rem; font-weight: 700; text-transform: uppercase; margin-bottom: 0.4rem;">Total Revenue</h3>
                    <span style="font-size: 1.6rem; font-weight: 800; color: #059669;">LKR <%= String.format("%,.2f", financialSummary.getOrDefault("total_revenue", 0.0)) %></span>
                    <small style="display: block; margin-top: 4px; color: #64748b; font-size: 0.75rem;">Treatment + Consultation</small>
                </div>
            </div>

            <!-- VISUAL GRAPH 1: BAR CHART (Treatment Revenue Breakdown) -->
            <div class="panel" style="margin-bottom: 2rem;">
                <div class="panel-header">
                    <h2 class="panel-title">📊 Treatment Revenue & Service Volume (Bar Graph)</h2>
                    <p class="panel-subtitle">Visual comparison of revenue generated and times performed across clinical treatment packages</p>
                </div>
                <div style="position: relative; min-height: 250px; width: 100%; padding: 10px;">
                    <canvas id="treatmentBarChart"></canvas>
                    <img id="treatmentBarChartImg" class="chart-print-img" alt="Treatment Revenue Bar Chart">
                </div>
            </div>

            <!-- VISUAL GRAPH 2: LINE GRAPH (Dentist Appointment Volume & Trends) -->
            <div class="panel page-break-before" style="margin-bottom: 2rem;">
                <div class="panel-header">
                    <h2 class="panel-title">📈 Dentist Appointment Volume & Distribution (Line Graph)</h2>
                    <p class="panel-subtitle">Visual trend curve showing total patient appointments handled per dentist</p>
                </div>
                <div style="position: relative; min-height: 250px; width: 100%; padding: 10px;">
                    <canvas id="dentistLineChart"></canvas>
                    <img id="dentistLineChartImg" class="chart-print-img" alt="Dentist Volume Line Chart">
                </div>
            </div>

            <!-- DETAILED DATA TABLES (Collapsed / Printable Section) -->
            <div class="panel" style="margin-bottom: 2rem;">
                <div class="panel-header">
                    <h2 class="panel-title">📋 Detailed Analytics Data Directory</h2>
                    <p class="panel-subtitle">Exact data tables for dentist appointment volumes and clinical treatment package earnings</p>
                </div>
                
                <h3 style="color: #0284c7; font-size: 1.05rem; margin-bottom: 0.75rem;">Dentist Appointment Volume Table</h3>
                <div style="overflow-x: auto; border-radius: 12px; border: 1px solid #e2e8f0; margin-bottom: 1.75rem;">
                    <table class="report-table" id="dentist-table" style="margin-top: 0;">
                        <thead>
                            <tr>
                                <th>Dentist Name</th>
                                <th style="text-align: right;">Total Appointments</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (dentistStats != null && !dentistStats.isEmpty()) { for (Map<String, Object> stat : dentistStats) { %>
                                <tr>
                                    <td style="font-weight: 600;"><%= stat.get("dentist_name") %></td>
                                    <td style="text-align: right; font-weight: 700; color: #0284c7;"><%= stat.get("appointment_count") %></td>
                                </tr>
                            <% } } else { %>
                                <tr><td colspan="2" style="text-align: center; color: #64748b;">No dentist statistics available for selected filter.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <h3 style="color: #059669; font-size: 1.05rem; margin-bottom: 0.75rem;">Treatment Revenue Breakdown Table</h3>
                <div style="overflow-x: auto; border-radius: 12px; border: 1px solid #e2e8f0;">
                    <table class="report-table" id="treatment-table" style="margin-top: 0;">
                        <thead>
                            <tr>
                                <th>Treatment Service</th>
                                <th style="text-align: center;">Times Performed</th>
                                <th style="text-align: right;">Total Generated (LKR)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (treatmentReport != null && !treatmentReport.isEmpty()) { for (Map<String, Object> tr : treatmentReport) { %>
                                <tr>
                                    <td style="font-weight: 600;"><%= tr.get("treatment_name") %></td>
                                    <td style="text-align: center; font-weight: 600;"><%= tr.get("appointment_count") %></td>
                                    <td style="text-align: right; font-weight: 700; color: #059669;">LKR <%= String.format("%,.2f", tr.get("total_earnings")) %></td>
                                </tr>
                            <% } } else { %>
                                <tr><td colspan="3" style="text-align: center; color: #64748b;">No treatment revenue records available for selected filter.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <!-- Hidden HTML Data Container for Clean Pure JavaScript Access -->
    <div id="csv-data-container" style="display: none;"
         data-filter="<%= activeFilterLabel %>"
         data-filter-date="<%= filterDate != null ? filterDate.trim() : "" %>"
         data-filter-month="<%= filterMonth != null ? filterMonth.trim() : "" %>"
         data-total="<%= apptCounts.getOrDefault("total", 0) %>"
         data-completed="<%= apptCounts.getOrDefault("completed", 0) %>"
         data-cancelled="<%= apptCounts.getOrDefault("cancelled", 0) %>"
         data-revenue="<%= financialSummary.getOrDefault("total_revenue", 0.0) %>">
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Extract Dentist Volume Data for Line Graph
            const dentistLabels = [];
            const dentistData = [];
            const dentistTrs = document.querySelectorAll("#dentist-table tbody tr");
            dentistTrs.forEach(function(tr) {
                const tds = tr.querySelectorAll("td");
                if (tds.length >= 2 && !tr.textContent.includes("No dentist statistics")) {
                    dentistLabels.push(tds[0].textContent.trim());
                    dentistData.push(parseInt(tds[1].textContent.trim(), 10) || 0);
                }
            });

            // Extract Treatment Revenue Data for Bar Graph
            const treatmentLabels = [];
            const treatmentRevenueData = [];
            const treatmentCountData = [];
            const treatmentTrs = document.querySelectorAll("#treatment-table tbody tr");
            treatmentTrs.forEach(function(tr) {
                const tds = tr.querySelectorAll("td");
                if (tds.length >= 3 && !tr.textContent.includes("No treatment revenue")) {
                    treatmentLabels.push(tds[0].textContent.trim());
                    treatmentCountData.push(parseInt(tds[1].textContent.trim(), 10) || 0);
                    let revNum = parseFloat(tds[2].textContent.replace(/LKR|,|\s/gi, "").trim()) || 0;
                    treatmentRevenueData.push(revNum);
                }
            });

            // Render Bar Chart (Treatment Revenue Breakdown)
            const ctxBar = document.getElementById("treatmentBarChart");
            if (ctxBar && typeof Chart !== "undefined") {
                new Chart(ctxBar, {
                    type: "bar",
                    data: {
                        labels: treatmentLabels.length > 0 ? treatmentLabels : ["No Data"],
                        datasets: [
                            {
                                label: "Total Revenue Generated (LKR)",
                                data: treatmentRevenueData.length > 0 ? treatmentRevenueData : [0],
                                backgroundColor: "rgba(2, 132, 199, 0.8)",
                                borderColor: "#0284c7",
                                borderWidth: 1.5,
                                borderRadius: 6
                            },
                            {
                                label: "Times Performed",
                                data: treatmentCountData.length > 0 ? treatmentCountData : [0],
                                backgroundColor: "rgba(16, 185, 129, 0.8)",
                                borderColor: "#10b981",
                                borderWidth: 1.5,
                                borderRadius: 6
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { position: "top" }
                        },
                        scales: {
                            y: { beginAtZero: true }
                        }
                    }
                });
            }

            // Render Line Chart (Dentist Appointment Volume Trend Curve)
            const ctxLine = document.getElementById("dentistLineChart");
            if (ctxLine && typeof Chart !== "undefined") {
                new Chart(ctxLine, {
                    type: "line",
                    data: {
                        labels: dentistLabels.length > 0 ? dentistLabels : ["No Data"],
                        datasets: [{
                            label: "Total Patient Appointments",
                            data: dentistData.length > 0 ? dentistData : [0],
                            borderColor: "#2563eb",
                            backgroundColor: "rgba(37, 99, 235, 0.15)",
                            borderWidth: 3,
                            fill: true,
                            tension: 0.35,
                            pointBackgroundColor: "#1d4ed8",
                            pointBorderColor: "#ffffff",
                            pointBorderWidth: 2,
                            pointRadius: 6,
                            pointHoverRadius: 8
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { position: "top" }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: { stepSize: 1 }
                            }
                        }
                    }
                });
            }
        });

        function printReport() {
            // 1. Convert Bar Chart Canvas to Image for PDF Print Engine
            const barCanvas = document.getElementById("treatmentBarChart");
            const barImg = document.getElementById("treatmentBarChartImg");
            if (barCanvas && barImg) {
                try {
                    barImg.src = barCanvas.toDataURL("image/png");
                } catch (e) {
                    console.error("Bar chart print convert error:", e);
                }
            }

            // 2. Convert Line Chart Canvas to Image for PDF Print Engine
            const lineCanvas = document.getElementById("dentistLineChart");
            const lineImg = document.getElementById("dentistLineChartImg");
            if (lineCanvas && lineImg) {
                try {
                    lineImg.src = lineCanvas.toDataURL("image/png");
                } catch (e) {
                    console.error("Line chart print convert error:", e);
                }
            }

            // 3. Trigger Print Window after brief DOM update delay
            setTimeout(function() {
                window.print();
            }, 150);
        }

        function downloadCSVReport() {
            const container = document.getElementById("csv-data-container");
            if (!container) return;

            let filterDateVal = container.dataset.filterDate || "";
            let filterMonthVal = container.dataset.filterMonth || "";
            let selectedFilterCriteria = "All Time Record Summary (No Date/Month Filter)";
            if (filterDateVal) {
                selectedFilterCriteria = "Filter by Specific Date: " + filterDateVal;
            } else if (filterMonthVal) {
                selectedFilterCriteria = "Filter by Specific Month: " + filterMonthVal;
            }

            let rows = [];
            rows.push(["Report Title", "Sunrise Dental Clinic Analytics & Financial Report"]);
            rows.push(["Applied Filter", selectedFilterCriteria]);
            rows.push(["Filter Date", filterDateVal ? filterDateVal : "None"]);
            rows.push(["Filter Month", filterMonthVal ? filterMonthVal : "None"]);
            rows.push([]);
            rows.push(["Category", "Detail", "Value"]);
            rows.push(["Summary", "Total Appointments", container.dataset.total || "0"]);
            rows.push(["Summary", "Completed Appointments", container.dataset.completed || "0"]);
            rows.push(["Summary", "Cancelled Appointments", container.dataset.cancelled || "0"]);
            rows.push(["Summary", "Total Revenue (LKR)", container.dataset.revenue || "0"]);

            const tables = document.querySelectorAll(".report-table");
            tables.forEach(function(table, index) {
                rows.push([]);
                const sectionTitle = index === 0 ? "Dentist Statistics" : "Treatment Revenue Breakdown";
                rows.push([sectionTitle]);

                const trs = table.querySelectorAll("tr");
                trs.forEach(function(tr) {
                    const cells = tr.querySelectorAll("th, td");
                    const rowData = Array.from(cells).map(function(cell) {
                        return cell.textContent.trim().replace(/\s+/g, " ");
                    });
                    if (rowData.length > 0) {
                        rows.push(rowData);
                    }
                });
            });

            const csvContent = rows.map(function(row) {
                return row.map(function(cell) {
                    return '"' + (cell || '').toString().replace(/"/g, '""') + '"';
                }).join(",");
            }).join("\n");

            let filename = "Sunrise_Dental_Report";
            if (filterDateVal) {
                filename += "_Date_" + filterDateVal;
            } else if (filterMonthVal) {
                filename += "_Month_" + filterMonthVal;
            }
            filename += ".csv";

            const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
            const link = document.createElement("a");
            const url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", filename);
            link.style.visibility = "hidden";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    </script>
</body>
</html>