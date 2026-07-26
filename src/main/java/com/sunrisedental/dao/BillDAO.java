package com.sunrisedental.dao;

import com.sunrisedental.model.Bill;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public interface BillDAO {
    Bill generateBill(String appointmentNumber, BigDecimal consultationFee);
    Bill generateBill(String appointmentNumber, BigDecimal consultationFee, String paymentMethod, BigDecimal cashGiven, BigDecimal balanceReturned);
    Bill getBillByAppointmentNumber(String appointmentNumber);
    Map<String, Object> getFinancialSummary();
    Map<String, Object> getFinancialSummary(String filterDate, String filterMonth);
    List<Map<String, Object>> getTreatmentRevenueReport();
    List<Map<String, Object>> getTreatmentRevenueReport(String filterDate, String filterMonth);
}
