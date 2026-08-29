package com.sunrisedental.controller;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.PatientDAO;
import com.sunrisedental.dao.impl.AppointmentDAOImpl;
import com.sunrisedental.dao.impl.PatientDAOImpl;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Patient;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.Random;

@WebServlet("/appointments")
public class AppointmentServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAOImpl();
    private final PatientDAO patientDAO = new PatientDAOImpl();
    private final Random random = new Random();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if ("update".equalsIgnoreCase(action)) {
            try {
                String apptNum = req.getParameter("appointment_number");
                String dentistName = req.getParameter("dentist_name");
                String treatmentIdStr = req.getParameter("treatment_id");
                String appointmentDateStr = req.getParameter("appointment_date");
                String appointmentTimeStr = req.getParameter("appointment_time");
                String status = req.getParameter("status");

                if (apptNum != null && dentistName != null && treatmentIdStr != null && appointmentDateStr != null && appointmentTimeStr != null) {
                    int treatmentId = Integer.parseInt(treatmentIdStr.trim());
                    Date appointmentDate = Date.valueOf(appointmentDateStr.trim());
                    String timeVal = appointmentTimeStr.trim();
                    if (timeVal.length() == 5) timeVal += ":00";
                    Time appointmentTime = Time.valueOf(timeVal);

                    Appointment app = new Appointment();
                    app.setAppointmentNumber(apptNum.trim());
                    app.setDentistName(dentistName.trim());
                    app.setTreatmentId(treatmentId);
                    app.setAppointmentDate(appointmentDate);
                    app.setAppointmentTime(appointmentTime);
                    app.setStatus(status != null ? status.trim() : "Scheduled");

                    boolean updated = appointmentDAO.updateAppointmentDetails(app);
                    if (updated) {
                        session.setAttribute("flashSuccess", "Appointment " + apptNum + " updated successfully!");
                    } else {
                        session.setAttribute("flashError", "Failed to update appointment details.");
                    }
                }
            } catch (Exception e) {
                session.setAttribute("flashError", "Error updating appointment: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-search&search_appt_num=" + req.getParameter("appointment_number"));
            return;
        }

        try {
            String nicInput = req.getParameter("search_patient_nic");
            String dentistName = req.getParameter("dentist_name");
            String treatmentIdStr = req.getParameter("treatment_id");
            String appointmentDateStr = req.getParameter("appointment_date");
            String appointmentTimeStr = req.getParameter("appointment_time");

            if (nicInput == null || nicInput.trim().isEmpty()) {
                session.setAttribute("flashError", "Please enter the Patient ID, Phone, or Name.");
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-register");
                return;
            }

            Patient patient = patientDAO.getPatientByNic(nicInput.trim());
            if (patient == null) {
                session.setAttribute("flashError", "Cannot schedule appointment! No registered patient found matching \"" + nicInput.trim() + "\". Please register the patient under Patient Registration first.");
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-register");
                return;
            }

            if (dentistName == null || dentistName.trim().isEmpty() ||
                treatmentIdStr == null || treatmentIdStr.trim().isEmpty() ||
                appointmentDateStr == null || appointmentDateStr.trim().isEmpty() ||
                appointmentTimeStr == null || appointmentTimeStr.trim().isEmpty()) {
                session.setAttribute("flashError", "All appointment fields are required.");
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-register");
                return;
            }

            int treatmentId = Integer.parseInt(treatmentIdStr.trim());
            Date appointmentDate = Date.valueOf(appointmentDateStr.trim());

            String timeVal = appointmentTimeStr.trim();
            if (timeVal.length() == 5) timeVal += ":00";
            Time appointmentTime = Time.valueOf(timeVal);

            // Double booking validation check
            String selectedSlot = timeVal.substring(0, 5);
            java.util.List<String> bookedTimes = appointmentDAO.getBookedTimes(dentistName.trim(), appointmentDate);
            if (bookedTimes.contains(selectedSlot)) {
                session.setAttribute("flashError", "⚠️ " + dentistName.trim() + " is ALREADY BOOKED at " + selectedSlot + " on " + appointmentDateStr.trim() + "! Please select an available time slot.");
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-register");
                return;
            }

            // Generate unique appointment number
            String apptNum = "APPT-" + (1000 + random.nextInt(9000));

            Appointment appointment = new Appointment();
            appointment.setAppointmentNumber(apptNum);
            appointment.setPatientName(patient.getPatientName());
            appointment.setContactNumber(patient.getPhoneNumber());
            appointment.setAddress(patient.getAddress());
            appointment.setDentistName(dentistName.trim());
            appointment.setTreatmentId(treatmentId);
            appointment.setAppointmentDate(appointmentDate);
            appointment.setAppointmentTime(appointmentTime);

            boolean success = appointmentDAO.createAppointment(appointment);

            if (success) {
                session.setAttribute("flashSuccess", "Appointment registered successfully! Appointment Number: " + appointment.getAppointmentNumber());
            } else {
                session.setAttribute("flashError", "Failed to register appointment.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Error creating appointment: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-register");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String appNum = req.getParameter("appointment_number");
        String status = req.getParameter("status");
        HttpSession session = req.getSession(false);

        if ("updateStatus".equalsIgnoreCase(action) && appNum != null && status != null && session != null) {
            boolean updated = appointmentDAO.updateAppointmentStatus(appNum.trim(), status.trim());
            if (updated) {
                session.setAttribute("flashSuccess", "Appointment status updated to " + status);
            } else {
                session.setAttribute("flashError", "Failed to update appointment status.");
            }
            resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-search&search_appt_num=" + appNum.trim());
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-register");
    }
}
