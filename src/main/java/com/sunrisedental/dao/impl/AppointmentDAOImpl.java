package com.sunrisedental.dao.impl;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.util.DBConnection;
import com.sunrisedental.model.Appointment;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AppointmentDAOImpl implements AppointmentDAO {

    @Override
    public boolean createAppointment(Appointment app) {
        String sql = "INSERT INTO appointments (appointment_number, patient_name, address, contact_number, dentist_name, treatment_id, appointment_date, appointment_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            if (app.getAppointmentNumber() == null || app.getAppointmentNumber().trim().isEmpty()) {
                app.setAppointmentNumber("APPT-" + (1000 + new java.util.Random().nextInt(9000)));
            }
            ps.setString(1, app.getAppointmentNumber());
            ps.setString(2, app.getPatientName());
            ps.setString(3, app.getAddress());
            ps.setString(4, app.getContactNumber());
            ps.setString(5, app.getDentistName());
            ps.setInt(6, app.getTreatmentId());
            ps.setDate(7, app.getAppointmentDate());
            ps.setTime(8, app.getAppointmentTime());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void syncPaidAppointments(Connection conn) {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE appointments SET status = 'Completed' WHERE appointment_number IN (SELECT appointment_number FROM bills WHERE payment_status = 'Paid') AND status != 'Completed'")) {
            ps.executeUpdate();
        } catch (Exception e) {
            // Ignore
        }
    }

    @Override
    public Appointment getAppointmentByNumber(String appointmentNumber) {
        String sql = "SELECT a.*, t.treatment_name, t.cost, b.payment_status FROM appointments a " +
                     "JOIN treatments t ON a.treatment_id = t.id " +
                     "LEFT JOIN bills b ON a.appointment_number = b.appointment_number " +
                     "WHERE a.appointment_number = ?";
        try (Connection conn = DBConnection.getConnection()) {
            syncPaidAppointments(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, appointmentNumber);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Appointment app = new Appointment();
                        app.setAppointmentNumber(rs.getString("appointment_number"));
                        app.setPatientName(rs.getString("patient_name"));
                        app.setAddress(rs.getString("address"));
                        app.setContactNumber(rs.getString("contact_number"));
                        app.setDentistName(rs.getString("dentist_name"));
                        app.setTreatmentId(rs.getInt("treatment_id"));
                        app.setAppointmentDate(rs.getDate("appointment_date"));
                        app.setAppointmentTime(rs.getTime("appointment_time"));
                        
                        String status = rs.getString("status");
                        String paymentStatus = rs.getString("payment_status");
                        if ("Paid".equalsIgnoreCase(paymentStatus)) {
                            status = "Completed";
                        }
                        app.setStatus(status);
                        app.setPaymentStatus(paymentStatus);
                        app.setTreatmentName(rs.getString("treatment_name"));
                        app.setTreatmentCost(rs.getBigDecimal("cost"));
                        return app;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Appointment> getAllAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, t.treatment_name, t.cost, b.payment_status FROM appointments a " +
                     "JOIN treatments t ON a.treatment_id = t.id " +
                     "LEFT JOIN bills b ON a.appointment_number = b.appointment_number " +
                     "ORDER BY a.appointment_date DESC, a.appointment_time DESC";
        try (Connection conn = DBConnection.getConnection()) {
            syncPaidAppointments(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Appointment app = new Appointment();
                    app.setAppointmentNumber(rs.getString("appointment_number"));
                    app.setPatientName(rs.getString("patient_name"));
                    app.setAddress(rs.getString("address"));
                    app.setContactNumber(rs.getString("contact_number"));
                    app.setDentistName(rs.getString("dentist_name"));
                    app.setTreatmentId(rs.getInt("treatment_id"));
                    app.setAppointmentDate(rs.getDate("appointment_date"));
                    app.setAppointmentTime(rs.getTime("appointment_time"));
                    
                    String status = rs.getString("status");
                    String paymentStatus = rs.getString("payment_status");
                    if ("Paid".equalsIgnoreCase(paymentStatus)) {
                        status = "Completed";
                    }
                    app.setStatus(status);
                    app.setPaymentStatus(paymentStatus);
                    app.setTreatmentName(rs.getString("treatment_name"));
                    app.setTreatmentCost(rs.getBigDecimal("cost"));
                    list.add(app);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Map<String, Object>> getDentistStatistics() {
        return getDentistStatistics(null, null);
    }

    @Override
    public List<Map<String, Object>> getDentistStatistics(String filterDate, String filterMonth) {
        List<Map<String, Object>> stats = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT dentist_name, COUNT(*) as appointment_count FROM appointments WHERE 1=1");
        
        if (filterDate != null && !filterDate.trim().isEmpty()) {
            sql.append(" AND appointment_date = ?");
        } else if (filterMonth != null && !filterMonth.trim().isEmpty()) {
            sql.append(" AND DATE_FORMAT(appointment_date, '%Y-%m') = ?");
        }
        
        sql.append(" GROUP BY dentist_name ORDER BY appointment_count DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIdx = 1;
            if (filterDate != null && !filterDate.trim().isEmpty()) {
                ps.setDate(paramIdx++, java.sql.Date.valueOf(filterDate));
            } else if (filterMonth != null && !filterMonth.trim().isEmpty()) {
                ps.setString(paramIdx++, filterMonth);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("dentist_name", rs.getString("dentist_name"));
                    map.put("appointment_count", rs.getInt("appointment_count"));
                    stats.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    @Override
    public Map<String, Integer> getAppointmentCounts(String filterDate, String filterMonth) {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("total", 0);
        counts.put("scheduled", 0);
        counts.put("completed", 0);
        counts.put("cancelled", 0);

        StringBuilder sql = new StringBuilder(
            "SELECT " +
            "  COUNT(*) as total, " +
            "  SUM(CASE WHEN status = 'Scheduled' THEN 1 ELSE 0 END) as scheduled, " +
            "  SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) as completed, " +
            "  SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) as cancelled " +
            "FROM appointments WHERE 1=1"
        );

        if (filterDate != null && !filterDate.trim().isEmpty()) {
            sql.append(" AND appointment_date = ?");
        } else if (filterMonth != null && !filterMonth.trim().isEmpty()) {
            sql.append(" AND DATE_FORMAT(appointment_date, '%Y-%m') = ?");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIdx = 1;
            if (filterDate != null && !filterDate.trim().isEmpty()) {
                ps.setDate(paramIdx++, java.sql.Date.valueOf(filterDate));
            } else if (filterMonth != null && !filterMonth.trim().isEmpty()) {
                ps.setString(paramIdx++, filterMonth);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    counts.put("total", rs.getInt("total"));
                    counts.put("scheduled", rs.getInt("scheduled"));
                    counts.put("completed", rs.getInt("completed"));
                    counts.put("cancelled", rs.getInt("cancelled"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    @Override
    public boolean updateAppointmentStatus(String appointmentNumber, String status) {
        String sql = "UPDATE appointments SET status = ? WHERE appointment_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, appointmentNumber);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateAppointmentDetails(Appointment app) {
        String sql = "UPDATE appointments SET dentist_name = ?, treatment_id = ?, appointment_date = ?, appointment_time = ?, status = ? WHERE appointment_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, app.getDentistName());
            ps.setInt(2, app.getTreatmentId());
            ps.setDate(3, app.getAppointmentDate());
            ps.setTime(4, app.getAppointmentTime());
            ps.setString(5, app.getStatus());
            ps.setString(6, app.getAppointmentNumber());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<String> getBookedTimes(String dentistName, java.sql.Date appointmentDate) {
        List<String> times = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(appointment_time, '%H:%i') as slot FROM appointments " +
                     "WHERE dentist_name = ? AND appointment_date = ? AND status != 'Cancelled'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dentistName);
            ps.setDate(2, appointmentDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    times.add(rs.getString("slot"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return times;
    }
}
