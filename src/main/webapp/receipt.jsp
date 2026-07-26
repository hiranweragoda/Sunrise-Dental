<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.sunrisedental.model.Bill" %>
<%@ page import="com.sunrisedental.model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Bill bill = (Bill) request.getAttribute("bill");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Receipt - Sunrise Dental Clinic</title>
    <link rel="stylesheet" href="css/style.css?v=10">
    <style>
        body {
            background-color: #f1f5f9;
            color: #0f172a;
            font-family: 'Outfit', sans-serif, Arial, sans-serif;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            margin: 0;
            padding: 0;
        }

        .receipt-container {
            max-width: 680px;
            margin: 2rem auto;
            width: 100%;
            padding: 0 1rem;
        }

        .receipt-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 2.5rem;
            box-shadow: 0 20px 40px -15px rgba(0, 0, 0, 0.07), 0 0 1px 1px rgba(0, 0, 0, 0.05);
            border-top: 5px solid #0284c7;
            color: #0f172a;
            position: relative;
        }

        .receipt-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px dashed #e2e8f0;
            padding-bottom: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .brand-title-receipt {
            font-size: 1.75rem;
            font-weight: 800;
            color: #0f172a;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .brand-subtitle-receipt {
            margin: 4px 0 0 0;
            color: #64748b;
            font-size: 0.85rem;
            font-weight: 500;
        }

        .receipt-badge {
            background: #dcfce7;
            color: #15803d;
            border: 1px solid #bbf7d0;
            font-weight: 700;
            font-size: 0.85rem;
            padding: 6px 14px;
            border-radius: 20px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .receipt-section-title {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            color: #64748b;
            margin-bottom: 0.75rem;
        }

        .receipt-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.6rem 0;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.95rem;
        }

        .receipt-row:last-child {
            border-bottom: none;
        }

        .receipt-label {
            color: #475569;
            font-weight: 500;
        }

        .receipt-val {
            font-weight: 700;
            color: #0f172a;
        }

        .receipt-total-box {
            background: #e0f2fe;
            border: 1.5px solid #bae6fd;
            border-radius: 12px;
            padding: 1.25rem;
            margin-top: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .receipt-total-label {
            font-size: 0.85rem;
            font-weight: 700;
            text-transform: uppercase;
            color: #0369a1;
        }

        .receipt-total-val {
            font-size: 1.6rem;
            font-weight: 800;
            color: #0284c7;
        }

        .cash-summary-box {
            margin-top: 1.25rem;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            padding: 1rem 1.25rem;
            border-radius: 12px;
        }

        .receipt-footer {
            text-align: center;
            margin-top: 2rem;
            border-top: 1px solid #e2e8f0;
            padding-top: 1.25rem;
            color: #64748b;
            font-size: 0.85rem;
        }

        /* PRINT STYLES - Fix blank page print issue */
        @media print {
            @page {
                size: A4 portrait;
                margin: 10mm;
            }

            /* Hide top action buttons and non-printable elements */
            .no-print, header, aside, button {
                display: none !important;
            }

            /* Reset html & body to pure block layout for print engine */
            html, body {
                background: #ffffff !important;
                color: #0f172a !important;
                font-family: Arial, sans-serif !important;
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

            .receipt-container {
                display: block !important;
                width: 100% !important;
                max-width: 100% !important;
                height: auto !important;
                min-height: auto !important;
                margin: 0 !important;
                padding: 0 !important;
                float: none !important;
                position: static !important;
                overflow: visible !important;
            }

            .receipt-card {
                display: block !important;
                background: #ffffff !important;
                color: #0f172a !important;
                border: 2px solid #cbd5e1 !important;
                border-top: 5px solid #0284c7 !important;
                box-shadow: none !important;
                margin: 0 !important;
                padding: 20px !important;
                border-radius: 8px !important;
                width: 100% !important;
                height: auto !important;
                min-height: auto !important;
                float: none !important;
                position: static !important;
                overflow: visible !important;
                page-break-inside: avoid !important;
                break-inside: avoid !important;
            }

            h1, h2, h3, h4, p, span, div, strong {
                color: #0f172a !important;
                opacity: 1 !important;
                visibility: visible !important;
            }

            .receipt-row {
                display: flex !important;
                justify-content: space-between !important;
                align-items: center !important;
                border-bottom: 1px solid #e2e8f0 !important;
                padding: 8px 0 !important;
            }

            .receipt-total-box {
                display: flex !important;
                justify-content: space-between !important;
                align-items: center !important;
                background: #e0f2fe !important;
                border: 1.5px solid #bae6fd !important;
                padding: 15px !important;
                border-radius: 8px !important;
            }

            .receipt-total-val {
                color: #0284c7 !important;
                font-weight: 800 !important;
            }

            .receipt-badge {
                background: #dcfce7 !important;
                color: #15803d !important;
                border: 1px solid #bbf7d0 !important;
            }

            .cash-summary-box {
                background: #f8fafc !important;
                border: 1px solid #cbd5e1 !important;
                padding: 12px !important;
                border-radius: 8px !important;
            }
        }
    </style>
</head>
<body>

    <!-- Header Action Buttons (Screen Only) -->
    <div class="no-print" style="max-width: 680px; margin: 1.5rem auto 0 auto; display: flex; justify-content: space-between; width: 100%; padding: 0 1rem;">
        <a href="dashboard?tab=tab-billing" class="btn btn-secondary" style="background: #ffffff; color: #334155; border: 1px solid #cbd5e1; padding: 10px 20px; border-radius: 10px; text-decoration: none; font-weight: 700; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">← Back to Billing Dashboard</a>
        <button onclick="window.print()" class="btn btn-primary" style="background: linear-gradient(135deg, #0284c7, #06b6d4); color: #ffffff; border: none; padding: 10px 24px; border-radius: 10px; font-weight: 700; cursor: pointer; font-size: 1rem; box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3);">🖨️ Print Payment Receipt</button>
    </div>

    <!-- Main Printable Receipt Card -->
    <div class="receipt-container">
        <div class="receipt-card">
            <!-- Receipt Header -->
            <div class="receipt-header">
                <div>
                    <h1 class="brand-title-receipt">
                        <span style="color: #0284c7;">🦷</span> Sunrise Dental Clinic
                    </h1>
                    <p class="brand-subtitle-receipt">Official Payment Receipt & Statement of Account</p>
                </div>
                <div style="text-align: right;">
                    <span class="receipt-badge">✓ PAID IN FULL</span>
                    <p style="margin: 6px 0 0 0; color: #64748b; font-size: 0.8rem; font-weight: 600;">Receipt #: <%= bill != null ? bill.getBillNumber() : "-" %></p>
                </div>
            </div>

            <% if (bill != null) { 
                boolean isCash = "Cash".equalsIgnoreCase(bill.getPaymentMethod());
            %>
                <!-- Patient & Appointment Details -->
                <div style="margin-bottom: 1.5rem;">
                    <div class="receipt-section-title">Patient & Invoice Summary</div>
                    <div class="receipt-row">
                        <span class="receipt-label">Invoice Number</span>
                        <span class="receipt-val" style="color: #0284c7;"><%= bill.getBillNumber() %></span>
                    </div>
                    <div class="receipt-row">
                        <span class="receipt-label">Appointment Number</span>
                        <span class="receipt-val"><%= bill.getAppointmentNumber() %></span>
                    </div>
                    <div class="receipt-row">
                        <span class="receipt-label">Patient Full Name</span>
                        <span class="receipt-val"><%= bill.getPatientName() %></span>
                    </div>
                    <div class="receipt-row">
                        <span class="receipt-label">Consulting Dentist</span>
                        <span class="receipt-val" style="color: #0284c7;"><%= bill.getDentistName() %></span>
                    </div>
                    <div class="receipt-row">
                        <span class="receipt-label">Treatment Service</span>
                        <span class="receipt-val" style="color: #059669;"><%= bill.getTreatmentName() %></span>
                    </div>
                    <div class="receipt-row">
                        <span class="receipt-label">Payment Method</span>
                        <span class="receipt-val" style="color: #0284c7;"><%= isCash ? "💵 Cash Payment" : "💳 Credit / Debit Card" %></span>
                    </div>
                    <div class="receipt-row">
                        <span class="receipt-label">Date & Time Issued</span>
                        <span class="receipt-val"><%= bill.getBillDate() %></span>
                    </div>
                </div>

                <!-- Financial Fee Breakdown -->
                <div style="margin-top: 1.5rem; border-top: 1px solid #e2e8f0; padding-top: 1.25rem;">
                    <div class="receipt-section-title">Financial Charges Breakdown</div>
                    <div class="receipt-row">
                        <span class="receipt-label">Treatment Package Price</span>
                        <span class="receipt-val">LKR <%= String.format("%,.2f", bill.getTreatmentCost()) %></span>
                    </div>
                    <div class="receipt-row">
                        <span class="receipt-label">Doctor Consultation Fee</span>
                        <span class="receipt-val">LKR <%= String.format("%,.2f", bill.getConsultationFee()) %></span>
                    </div>
                </div>

                <!-- Total Amount Paid Box -->
                <div class="receipt-total-box">
                    <div>
                        <span class="receipt-total-label">Total Amount Paid</span>
                        <p style="margin: 2px 0 0 0; color: #64748b; font-size: 0.75rem;">Includes all treatment & consultation fees</p>
                    </div>
                    <div class="receipt-total-val">
                        LKR <%= String.format("%,.2f", bill.getTotalAmount()) %>
                    </div>
                </div>

                <!-- Cash Payment Calculation Breakdown -->
                <% if (isCash && bill.getCashGiven() != null) { %>
                    <div class="cash-summary-box">
                        <div class="receipt-row">
                            <span class="receipt-label">Cash Tendered by Patient</span>
                            <span class="receipt-val">LKR <%= String.format("%,.2f", bill.getCashGiven()) %></span>
                        </div>
                        <div class="receipt-row">
                            <span class="receipt-label">Balance Change Returned</span>
                            <span class="receipt-val" style="color: #16a34a; font-size: 1.05rem;">LKR <%= String.format("%,.2f", bill.getBalanceReturned() != null ? bill.getBalanceReturned() : java.math.BigDecimal.ZERO) %></span>
                        </div>
                    </div>
                <% } %>

                <!-- Footer Signature & Thank You -->
                <div class="receipt-footer">
                    <p style="margin: 0; font-weight: 700; color: #0f172a; font-size: 0.95rem;">Thank you for visiting Sunrise Dental Clinic!</p>
                    <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.8rem;">Issued by System Staff: <strong><%= sessionUser.getFullName() %></strong> (<%= sessionUser.getRole() %>)</p>
                </div>
            <% } else { %>
                <div style="text-align: center; color: #ef4444; padding: 2.5rem;">
                    <p style="font-size: 1.1rem; font-weight: 700;">⚠️ No receipt data available to display.</p>
                    <a href="dashboard?tab=tab-billing" style="color: #0284c7; font-weight: 600; text-decoration: underline;">Return to Billing Dashboard</a>
                </div>
            <% } %>
        </div>
    </div>

</body>
</html>
