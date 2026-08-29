package com.sunrisedental.controller;

import com.sunrisedental.dao.PatientDAO;
import com.sunrisedental.dao.impl.PatientDAOImpl;
import com.sunrisedental.model.Patient;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/patients")
public class PatientServlet extends HttpServlet {

    private final PatientDAO patientDAO = new PatientDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            String idStr = req.getParameter("id");
            String action = req.getParameter("action");
            String patientName = req.getParameter("patient_name");
            String nicPassport = req.getParameter("nic_passport");
            String phoneNumber = req.getParameter("phone_number");
            String address = req.getParameter("address");

            if ("delete".equalsIgnoreCase(action)) {
                if (idStr != null && !idStr.trim().isEmpty()) {
                    int id = Integer.parseInt(idStr.trim());
                    boolean deleted = patientDAO.deletePatient(id);
                    if (deleted) {
                        session.setAttribute("flashSuccess", "Patient profile deleted successfully.");
                    } else {
                        session.setAttribute("flashError", "Failed to delete patient profile.");
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-patients");
                return;
            }

            if (patientName == null || patientName.trim().isEmpty() ||
                phoneNumber == null || phoneNumber.trim().isEmpty()) {
                session.setAttribute("flashError", "Patient Name and Contact Phone Number are required.");
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-patients");
                return;
            }

            boolean isUpdate = (idStr != null && !idStr.trim().isEmpty() && !idStr.trim().equals("0"));
            Patient patient = new Patient();
            patient.setPatientName(patientName.trim());
            patient.setNicPassport(nicPassport != null ? nicPassport.trim() : "");
            patient.setPhoneNumber(phoneNumber.trim());
            patient.setAddress(address != null ? address.trim() : "");

            boolean success;
            if (isUpdate) {
                patient.setId(Integer.parseInt(idStr.trim()));
                success = patientDAO.updatePatient(patient);
            } else {
                success = patientDAO.createPatient(patient);
            }

            if (success) {
                String patID = (patient.getNicPassport() != null && !patient.getNicPassport().trim().isEmpty()) ? patient.getNicPassport().trim() : String.format("PAT-%04d", patient.getId());
                session.setAttribute("flashSuccess", isUpdate ? "✓ Patient profile updated successfully (" + patID + ")." : "✓ Patient Registered Successfully! Generated Patient ID: " + patID);
            } else {
                session.setAttribute("flashError", isUpdate ? "Failed to update patient profile." : "Failed to register patient.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Error processing patient record: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-patients");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String idStr = req.getParameter("id");
        HttpSession session = req.getSession(false);

        if ("delete".equalsIgnoreCase(action) && idStr != null && session != null && session.getAttribute("user") != null) {
            try {
                int id = Integer.parseInt(idStr.trim());
                boolean deleted = patientDAO.deletePatient(id);
                if (deleted) {
                    session.setAttribute("flashSuccess", "Patient profile deleted successfully.");
                } else {
                    session.setAttribute("flashError", "Failed to delete patient profile.");
                }
            } catch (Exception e) {
                session.setAttribute("flashError", "Failed to delete patient.");
            }
        }
        resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-patients");
    }
}
