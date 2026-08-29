package com.sunrisedental.controller;

import com.sunrisedental.dao.*;
import com.sunrisedental.dao.impl.*;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Patient;
import com.sunrisedental.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = {"/login", "/login.html", "/dashboard", "/reports", "/receipt"})
public class ViewServlet extends HttpServlet {

    private final PatientDAO patientDAO = new PatientDAOImpl();
    private final DentistDAO dentistDAO = new DentistDAOImpl();
    private final TreatmentDAO treatmentDAO = new TreatmentDAOImpl();
    private final AppointmentDAO appointmentDAO = new AppointmentDAOImpl();
    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);

        if ("/login".equals(path) || "/login.html".equals(path)) {
            if (isLoggedIn) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
            }
        } else if ("/dashboard".equals(path)) {
            if (!isLoggedIn) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            User user = (User) session.getAttribute("user");

            // Populate data attributes for traditional server-side rendering
            req.setAttribute("patients", patientDAO.getAllPatients());
            req.setAttribute("dentists", dentistDAO.getAllDentists());
            req.setAttribute("treatments", treatmentDAO.getAllTreatments());
            req.setAttribute("appointments", appointmentDAO.getAllAppointments());

            if ("Admin".equalsIgnoreCase(user.getRole())) {
                req.setAttribute("users", userDAO.getAllUsers());
            }

            // Handle patient NIC verification parameter if submitted via form
            String nicParam = req.getParameter("nic");
            if (nicParam != null && !nicParam.trim().isEmpty()) {
                Patient matchedPatient = patientDAO.getPatientByNic(nicParam.trim());
                if (matchedPatient != null) {
                    req.setAttribute("verifiedPatient", matchedPatient);
                    req.setAttribute("verifySuccess", "✓ Patient Verified: " + matchedPatient.getPatientName() + " (" + matchedPatient.getPhoneNumber() + ")");
                } else {
                    req.setAttribute("verifyError", "❌ No registered patient found with NIC/Passport \"" + nicParam.trim() + "\". Please register under Patient Registration first.");
                }
            }

            // Handle appointment number search parameter
            String searchApptNum = req.getParameter("search_appt_num");
            if (searchApptNum != null && !searchApptNum.trim().isEmpty()) {
                Appointment matchedAppt = appointmentDAO.getAppointmentByNumber(searchApptNum.trim());
                if (matchedAppt != null) {
                    req.setAttribute("searchedAppointment", matchedAppt);
                    req.setAttribute("searchSuccess", "✓ Appointment Record Found!");
                } else {
                    req.setAttribute("searchError", "❌ No appointment record found for Appointment Number \"" + searchApptNum.trim() + "\".");
                }
            }

            // Handle appointment number lookup for billing tab
            String billApptNum = req.getParameter("bill_appt_num");
            if (billApptNum != null && !billApptNum.trim().isEmpty()) {
                Appointment matchedBillAppt = appointmentDAO.getAppointmentByNumber(billApptNum.trim());
                if (matchedBillAppt != null) {
                    req.setAttribute("selectedBillAppt", matchedBillAppt);
                } else {
                    req.setAttribute("billApptError", "❌ No appointment record found for Appointment Number \"" + billApptNum.trim() + "\".");
                }
            }

            // Flash messages from session
            if (session.getAttribute("flashSuccess") != null) {
                req.setAttribute("flashSuccess", session.getAttribute("flashSuccess"));
                session.removeAttribute("flashSuccess");
            }
            if (session.getAttribute("flashError") != null) {
                req.setAttribute("flashError", session.getAttribute("flashError"));
                session.removeAttribute("flashError");
            }

            req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
        } else if ("/reports".equals(path)) {
            if (!isLoggedIn) {
                resp.sendRedirect(req.getContextPath() + "/login");
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-reports");
            }
        } else if ("/receipt".equals(path)) {
            if (!isLoggedIn) {
                resp.sendRedirect(req.getContextPath() + "/login");
            } else {
                req.getRequestDispatcher("/receipt.jsp").forward(req, resp);
            }
        }
    }
}
