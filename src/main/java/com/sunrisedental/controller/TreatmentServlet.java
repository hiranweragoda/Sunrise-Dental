package com.sunrisedental.controller;

import com.google.gson.Gson;
import com.sunrisedental.dao.TreatmentDAO;
import com.sunrisedental.dao.impl.TreatmentDAOImpl;
import com.sunrisedental.model.Treatment;
import com.sunrisedental.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(urlPatterns = {"/treatments", "/api/treatments", "/api/treatments/*"})
public class TreatmentServlet extends HttpServlet {
    private final TreatmentDAO treatmentDAO = new TreatmentDAOImpl();
    private final Gson gson = new Gson();

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
                boolean deleted = treatmentDAO.deleteTreatment(id);
                if (deleted && session != null) {
                    session.setAttribute("flashSuccess", "Treatment service deleted successfully.");
                } else if (session != null) {
                    session.setAttribute("flashError", "Failed to delete treatment service.");
                }
            } catch (Exception e) {
                if (session != null) session.setAttribute("flashError", "Error deleting treatment: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-treatments");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-treatments");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (!isAdmin(req)) {
            if (session != null) session.setAttribute("flashError", "Only administrators can manage treatment services.");
            resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-treatments");
            return;
        }

        try {
            String idStr = req.getParameter("id");
            String treatmentName = req.getParameter("treatment_name");
            String costStr = req.getParameter("cost");
            String action = req.getParameter("action");

            if ("delete".equalsIgnoreCase(action)) {
                if (idStr != null && !idStr.trim().isEmpty()) {
                    int id = Integer.parseInt(idStr.trim());
                    boolean deleted = treatmentDAO.deleteTreatment(id);
                    if (deleted && session != null) {
                        session.setAttribute("flashSuccess", "Treatment service deleted successfully.");
                    } else if (session != null) {
                        session.setAttribute("flashError", "Failed to delete treatment service.");
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-treatments");
                return;
            }

            if (treatmentName == null || treatmentName.trim().isEmpty() ||
                costStr == null || costStr.trim().isEmpty()) {
                if (session != null) session.setAttribute("flashError", "Treatment Name and Price (Cost) are required.");
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-treatments");
                return;
            }

            BigDecimal cost = new BigDecimal(costStr.trim());
            if (cost.compareTo(BigDecimal.ZERO) < 0) {
                if (session != null) session.setAttribute("flashError", "Cost cannot be negative.");
                resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-treatments");
                return;
            }

            boolean isUpdate = (idStr != null && !idStr.trim().isEmpty() && !idStr.trim().equals("0"));

            Treatment t = new Treatment();
            t.setTreatmentName(treatmentName.trim());
            t.setCost(cost);

            boolean success;
            if (isUpdate) {
                t.setId(Integer.parseInt(idStr.trim()));
                success = treatmentDAO.updateTreatment(t);
            } else {
                success = treatmentDAO.createTreatment(t);
            }

            if (success && session != null) {
                session.setAttribute("flashSuccess", isUpdate ? "Treatment service package updated successfully!" : "Treatment service package created successfully!");
            } else if (session != null) {
                session.setAttribute("flashError", isUpdate ? "Failed to update treatment service package." : "Failed to create treatment service package.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (session != null) session.setAttribute("flashError", "Error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard?tab=tab-treatments");
    }
}
