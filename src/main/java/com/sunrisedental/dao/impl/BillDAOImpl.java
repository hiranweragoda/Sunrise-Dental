package com.sunrisedental.dao.impl;

import com.sunrisedental.dao.BillDAO;
import com.sunrisedental.util.DBConnection;
import com.sunrisedental.model.Bill;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BillDAOImpl implements BillDAO {

    @Override
    public Bill generateBill(String appointmentNumber, BigDecimal consultationFee) {
        return generateBill(appointmentNumber, consultationFee, "Cash", null, null);
    }

    @Override
    public Bill generateBill(String appointmentNumber, BigDecimal consultationFee, String paymentMethod, BigDecimal cashGiven, BigDecimal balanceReturned) {
        String sql = "{call GenerateBill(?, ?, ?, ?)}";
        try (Connection conn = DBConnection.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setString(1, appointmentNumber);
            cs.setBigDecimal(2, consultationFee);
            cs.registerOutParameter(3, Types.INTEGER);
            cs.registerOutParameter(4, Types.DECIMAL);

            cs.execute();

            int billId = cs.getInt(3);
            BigDecimal totalAmount = cs.getBigDecimal(4);

            if (billId > 0) {
                // Update payment method details directly in bills table
                String updateBillSql = "UPDATE bills SET payment_method = ?, cash_given = ?, balance_returned = ? WHERE bill_id = ?";
                try (PreparedStatement updatePs = conn.prepareStatement(updateBillSql)) {
                    updatePs.setString(1, paymentMethod != null ? paymentMethod : "Cash");
                    updatePs.setBigDecimal(2, cashGiven);
                    updatePs.setBigDecimal(3, balanceReturned);
                    updatePs.setInt(4, billId);
                    updatePs.executeUpdate();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                // Automatically update appointment status to 'Completed' upon bill generation & payment
                String updateApptSql = "UPDATE appointments SET status = 'Completed' WHERE appointment_number = ?";
                try (PreparedStatement apptPs = conn.prepareStatement(updateApptSql)) {
                    apptPs.setString(1, appointmentNumber);
                    apptPs.executeUpdate();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                Bill bill = getBillByAppointmentNumber(appointmentNumber);
                if (bill != null) {
                    bill.setPaymentMethod(paymentMethod != null ? paymentMethod : "Cash");
                    bill.setCashGiven(cashGiven);
                    bill.setBalanceReturned(balanceReturned);
                }
                return bill;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Bill getBillByAppointmentNumber(String appointmentNumber) {
        String sql = "SELECT b.*, a.patient_name, a.dentist_name, t.treatment_name, t.cost as treatment_cost " +
                     "FROM bills b " +
                     "JOIN appointments a ON b.appointment_number = a.appointment_number " +
                     "JOIN treatments t ON a.treatment_id = t.id " +
                     "WHERE b.appointment_number = ? ORDER BY b.bill_id DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, appointmentNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Bill bill = new Bill();
                    bill.setBillId(rs.getInt("bill_id"));
                    bill.setAppointmentNumber(rs.getString("appointment_number"));
                    bill.setConsultationFee(rs.getBigDecimal("consultation_fee"));
                    bill.setTotalCost(rs.getBigDecimal("total_cost"));
                    bill.setBillDate(rs.getTimestamp("bill_date"));
                    bill.setPaymentStatus(rs.getString("payment_status"));
                    bill.setPatientName(rs.getString("patient_name"));
                    bill.setDentistName(rs.getString("dentist_name"));
                    bill.setTreatmentName(rs.getString("treatment_name"));
                    bill.setTreatmentCost(rs.getBigDecimal("treatment_cost"));
                    
                    String method = rs.getString("payment_method");
                    bill.setPaymentMethod(method != null ? method : "Cash");
                    bill.setCashGiven(rs.getBigDecimal("cash_given"));
                    bill.setBalanceReturned(rs.getBigDecimal("balance_returned"));
                    return bill;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Map<String, Object> getFinancialSummary() {
        return getFinancialSummary(null, null);
    }

    @Override
    public Map<String, Object> getFinancialSummary(String filterDate, String filterMonth) {
        Map<String, Object> summary = new HashMap<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) as total_bills, SUM(total_cost) as total_revenue, SUM(consultation_fee) as total_consultation_fees FROM bills WHERE 1=1");

        if (filterDate != null && !filterDate.trim().isEmpty()) {
            sql.append(" AND DATE(bill_date) = ?");
        } else if (filterMonth != null && !filterMonth.trim().isEmpty()) {
            sql.append(" AND DATE_FORMAT(bill_date, '%Y-%m') = ?");
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
                    summary.put("total_bills", rs.getInt("total_bills"));
                    BigDecimal revenue = rs.getBigDecimal("total_revenue");
                    summary.put("total_revenue", revenue != null ? revenue : BigDecimal.ZERO);
                    BigDecimal fees = rs.getBigDecimal("total_consultation_fees");
                    summary.put("total_consultation_fees", fees != null ? fees : BigDecimal.ZERO);
                } else {
                    summary.put("total_bills", 0);
                    summary.put("total_revenue", BigDecimal.ZERO);
                    summary.put("total_consultation_fees", BigDecimal.ZERO);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            summary.put("total_bills", 0);
            summary.put("total_revenue", BigDecimal.ZERO);
            summary.put("total_consultation_fees", BigDecimal.ZERO);
        }
        return summary;
    }

    @Override
    public List<Map<String, Object>> getTreatmentRevenueReport() {
        return getTreatmentRevenueReport(null, null);
    }

    @Override
    public List<Map<String, Object>> getTreatmentRevenueReport(String filterDate, String filterMonth) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT t.treatment_name, COUNT(a.appointment_number) as appointment_count, SUM(b.total_cost) as total_earnings " +
            "FROM treatments t " +
            "LEFT JOIN appointments a ON t.id = a.treatment_id "
        );

        if (filterDate != null && !filterDate.trim().isEmpty()) {
            sql.append(" AND a.appointment_date = ? ");
        } else if (filterMonth != null && !filterMonth.trim().isEmpty()) {
            sql.append(" AND DATE_FORMAT(a.appointment_date, '%Y-%m') = ? ");
        }

        sql.append(
            "LEFT JOIN bills b ON a.appointment_number = b.appointment_number " +
            "GROUP BY t.id, t.treatment_name " +
            "ORDER BY total_earnings DESC"
        );

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
                    map.put("treatment_name", rs.getString("treatment_name"));
                    map.put("appointment_count", rs.getInt("appointment_count"));
                    BigDecimal earnings = rs.getBigDecimal("total_earnings");
                    map.put("total_earnings", earnings != null ? earnings : BigDecimal.ZERO);
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
