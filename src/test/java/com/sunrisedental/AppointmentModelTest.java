package com.sunrisedental;

import com.sunrisedental.model.Appointment;
import org.junit.Test;
import static org.junit.Assert.*;

import java.sql.Date;
import java.sql.Time;

public class AppointmentModelTest {

    @Test
    public void testAppointmentDetailsSettersAndGetters() {
        Appointment appointment = new Appointment();
        appointment.setAppointmentNumber("APPT-1001");
        appointment.setPatientName("Sunil Silva");
        appointment.setContactNumber("0719876543");
        appointment.setAddress("Kandy");
        appointment.setDentistName("Dr. Samantha Perera");
        appointment.setTreatmentId(2);
        appointment.setAppointmentDate(Date.valueOf("2026-09-01"));
        appointment.setAppointmentTime(Time.valueOf("10:30:00"));
        appointment.setStatus("Scheduled");

        assertEquals("APPT-1001", appointment.getAppointmentNumber());
        assertEquals("Sunil Silva", appointment.getPatientName());
        assertEquals("Dr. Samantha Perera", appointment.getDentistName());
        assertEquals("Scheduled", appointment.getStatus());
    }

    @Test
    public void testAppointmentStatusChange() {
        Appointment appointment = new Appointment();
        appointment.setStatus("Scheduled");
        assertEquals("Scheduled", appointment.getStatus());

        appointment.setStatus("Completed");
        assertEquals("Completed", appointment.getStatus());
    }
}
