package com.sunrisedental.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Bill {
    private int billId;
    private String appointmentNumber;
    private BigDecimal consultationFee;
    private BigDecimal totalCost;
    private Timestamp billDate;
    private String paymentStatus;

    // Payment details
    private String paymentMethod; // "Cash" or "Card"
    private BigDecimal cashGiven;
    private BigDecimal balanceReturned;

    // Optional join fields for receipt formatting
    private String patientName;
    private String dentistName;
    private String treatmentName;
    private BigDecimal treatmentCost;

    public Bill() {
    }

    public int getBillId() {
        return billId;
    }

    public void setBillId(int billId) {
        this.billId = billId;
    }

    public String getBillNumber() {
        return "INV-" + (1000 + billId);
    }

    public String getAppointmentNumber() {
        return appointmentNumber;
    }

    public void setAppointmentNumber(String appointmentNumber) {
        this.appointmentNumber = appointmentNumber;
    }

    public BigDecimal getConsultationFee() {
        return consultationFee;
    }

    public void setConsultationFee(BigDecimal consultationFee) {
        this.consultationFee = consultationFee;
    }

    public BigDecimal getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(BigDecimal totalCost) {
        this.totalCost = totalCost;
    }

    public BigDecimal getTotalAmount() {
        return totalCost;
    }

    public Timestamp getBillDate() {
        return billDate;
    }

    public void setBillDate(Timestamp billDate) {
        this.billDate = billDate;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getPaymentMethod() {
        return paymentMethod != null ? paymentMethod : "Cash";
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public BigDecimal getCashGiven() {
        return cashGiven;
    }

    public void setCashGiven(BigDecimal cashGiven) {
        this.cashGiven = cashGiven;
    }

    public BigDecimal getBalanceReturned() {
        return balanceReturned;
    }

    public void setBalanceReturned(BigDecimal balanceReturned) {
        this.balanceReturned = balanceReturned;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getDentistName() {
        return dentistName;
    }

    public void setDentistName(String dentistName) {
        this.dentistName = dentistName;
    }

    public String getTreatmentName() {
        return treatmentName;
    }

    public void setTreatmentName(String treatmentName) {
        this.treatmentName = treatmentName;
    }

    public BigDecimal getTreatmentCost() {
        return treatmentCost;
    }

    public void setTreatmentCost(BigDecimal treatmentCost) {
        this.treatmentCost = treatmentCost;
    }
}
