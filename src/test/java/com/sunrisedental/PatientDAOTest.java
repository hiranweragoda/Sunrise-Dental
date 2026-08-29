package com.sunrisedental;

import com.sunrisedental.dao.PatientDAO;
import com.sunrisedental.dao.impl.PatientDAOImpl;
import com.sunrisedental.model.Patient;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

import java.util.List;

public class PatientDAOTest {

    private PatientDAO patientDAO;

    @Before
    public void setUp() {
        patientDAO = new PatientDAOImpl();
    }

    @Test
    public void testGetAllPatientsNotNull() {
        List<Patient> patients = patientDAO.getAllPatients();
        assertNotNull("Patient list retrieved from DAO should not be null", patients);
    }

    @Test
    public void testGetPatientByNicOrId() {
        // Test searching with a default key or non-existent key to verify SQL safety
        Patient patient = patientDAO.getPatientByNic("PAT-0001");
        // Should return patient object or null cleanly without throwing SQL Exception
        if (patient != null) {
            assertNotNull(patient.getPatientName());
        }
    }
}
