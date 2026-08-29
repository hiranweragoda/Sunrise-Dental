package com.sunrisedental.controller;

import com.sunrisedental.dao.DentistDAO;
import com.sunrisedental.dao.impl.DentistDAOImpl;
import com.sunrisedental.model.Dentist;
import com.sunrisedental.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/dentists")
public class DentistServlet extends HttpServlet {
    private final DentistDAO dentistDAO = new DentistDAOImpl();

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User sessionUser = (User) session.getAttribute("user");
            return "Admin".equalsIgnoreCase(sessionUser.getRole());
        }
        return false;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String idStr = req.getParameter("id");
        HttpSession session = req.getSession(false);

        if ("delete".equalsIgnoreCase(action) && idStr != null && !idStr.trim().isEmpty() && isAdmin(req)) {
            try {
                int id = Integer.parseInt(idStr.trim());
                boolean deleted = dentistDAO.deleteDentist(id);
                if (deleted && session != null) {
                    session.setAttribute("flashSuccess", "Dentist profile deleted successfully.");
                } else if (session != null) {
                    session.setAttribute("flashError", "Failed to delete dentist profile.");
                }
            } catch (Exception e) {
                if (session != null) session.setAttribute("flashError", "Error deleting dentist: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-dentists");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-dentists");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (!isAdmin(req)) {
            if (session != null) session.setAttribute("flashError", "Only administrators can manage dentist records.");
            resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-dentists");
            return;
        }

        try {
            String idStr = req.getParameter("id");
            String dentistName = req.getParameter("dentist_name");
            String specialization = req.getParameter("specialization");
            String contactNumber = req.getParameter("contact_number");
            String action = req.getParameter("action");

            if ("delete".equalsIgnoreCase(action)) {
                if (idStr != null && !idStr.trim().isEmpty()) {
                    int id = Integer.parseInt(idStr.trim());
                    boolean deleted = dentistDAO.deleteDentist(id);
                    if (deleted && session != null) {
                        session.setAttribute("flashSuccess", "Dentist profile deleted successfully.");
                    } else if (session != null) {
                        session.setAttribute("flashError", "Failed to delete dentist record.");
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-dentists");
                return;
            }

            if (dentistName == null || dentistName.trim().isEmpty() ||
                specialization == null || specialization.trim().isEmpty()) {
                if (session != null) session.setAttribute("flashError", "Dentist Name and Specialization are required.");
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-dentists");
                return;
            }

            boolean isUpdate = (idStr != null && !idStr.trim().isEmpty() && !idStr.trim().equals("0"));

            Dentist d = new Dentist();
            d.setDentistName(dentistName.trim());
            d.setSpecialization(specialization.trim());
            d.setContactNumber(contactNumber != null ? contactNumber.trim() : "");

            boolean success;
            if (isUpdate) {
                d.setId(Integer.parseInt(idStr.trim()));
                success = dentistDAO.updateDentist(d);
            } else {
                success = dentistDAO.createDentist(d);
            }

            if (success && session != null) {
                session.setAttribute("flashSuccess", isUpdate ? "Dentist profile updated successfully!" : "Dentist registered successfully!");
            } else if (session != null) {
                session.setAttribute("flashError", isUpdate ? "Failed to update dentist record." : "Failed to register dentist.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (session != null) session.setAttribute("flashError", "Error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-dentists");
    }
}
