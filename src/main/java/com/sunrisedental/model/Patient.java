package com.sunrisedental.model;

public class Patient {
    private int id;
    private String patientName;
    private String patientIdCode;
    private String address;
    private String phoneNumber;

    public Patient() {}

    public Patient(int id, String patientName, String patientIdCode, String address, String phoneNumber) {
        this.id = id;
        this.patientName = patientName;
        this.patientIdCode = patientIdCode;
        this.address = address;
        this.phoneNumber = phoneNumber;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getPatientIdCode() { return patientIdCode; }
    public void setPatientIdCode(String patientIdCode) { this.patientIdCode = patientIdCode; }

    // Backward compatibility getters
    public String getNicPassport() { return patientIdCode; }
    public void setNicPassport(String nicPassport) { this.patientIdCode = nicPassport; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
}
