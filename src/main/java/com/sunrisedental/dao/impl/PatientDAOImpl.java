package com.sunrisedental.dao.impl;

import com.sunrisedental.dao.PatientDAO;
import com.sunrisedental.model.Patient;
import com.sunrisedental.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PatientDAOImpl implements PatientDAO {

    @Override
    public List<Patient> getAllPatients() {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT id, patient_name, patient_id, address, phone_number FROM patients ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Patient(
                    rs.getInt("id"),
                    rs.getString("patient_name"),
                    rs.getString("patient_id"),
                    rs.getString("address"),
                    rs.getString("phone_number")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Patient getPatientById(int id) {
        String sql = "SELECT id, patient_name, patient_id, address, phone_number FROM patients WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Patient(
                        rs.getInt("id"),
                        rs.getString("patient_name"),
                        rs.getString("patient_id"),
                        rs.getString("address"),
                        rs.getString("phone_number")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Patient getPatientByNic(String searchKey) {
        if (searchKey == null || searchKey.trim().isEmpty()) return null;
        String key = searchKey.trim();
        String sql = "SELECT id, patient_name, patient_id, address, phone_number FROM patients WHERE patient_id = ? OR phone_number = ? OR CAST(id AS CHAR) = ? OR CONCAT('PAT-', LPAD(id, 4, '0')) = ? OR CONCAT('PAT-', id) = ? OR LOWER(patient_name) LIKE LOWER(?) LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            ps.setString(2, key);
            ps.setString(3, key);
            ps.setString(4, key.toUpperCase());
            ps.setString(5, key.toUpperCase());
            ps.setString(6, "%" + key + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Patient(
                        rs.getInt("id"),
                        rs.getString("patient_name"),
                        rs.getString("patient_id"),
                        rs.getString("address"),
                        rs.getString("phone_number")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean createPatient(Patient patient) {
        String sql = "INSERT INTO patients (patient_name, patient_id, address, phone_number) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, patient.getPatientName());
            ps.setString(2, (patient.getPatientIdCode() != null && !patient.getPatientIdCode().trim().isEmpty()) ? patient.getPatientIdCode().trim() : "");
            ps.setString(3, patient.getAddress());
            ps.setString(4, patient.getPhoneNumber());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int newId = generatedKeys.getInt(1);
                        patient.setId(newId);
                        if (patient.getPatientIdCode() == null || patient.getPatientIdCode().trim().isEmpty()) {
                            String autoNic = String.format("PAT-%04d", newId);
                            patient.setPatientIdCode(autoNic);
                            try (PreparedStatement updatePs = conn.prepareStatement("UPDATE patients SET patient_id = ? WHERE id = ?")) {
                                updatePs.setString(1, autoNic);
                                updatePs.setInt(2, newId);
                                updatePs.executeUpdate();
                            }
                        }
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updatePatient(Patient patient) {
        String sql = "UPDATE patients SET patient_name = ?, patient_id = ?, address = ?, phone_number = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patient.getPatientName());
            ps.setString(2, (patient.getPatientIdCode() != null && !patient.getPatientIdCode().trim().isEmpty()) ? patient.getPatientIdCode().trim() : String.format("PAT-%04d", patient.getId()));
            ps.setString(3, patient.getAddress());
            ps.setString(4, patient.getPhoneNumber());
            ps.setInt(5, patient.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean deletePatient(int id) {
        String sql = "DELETE FROM patients WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
