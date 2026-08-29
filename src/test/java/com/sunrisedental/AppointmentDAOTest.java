package com.sunrisedental;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.impl.AppointmentDAOImpl;
import com.sunrisedental.model.Appointment;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

import java.sql.Date;
import java.util.List;

public class AppointmentDAOTest {

    private AppointmentDAO appointmentDAO;

    @Before
    public void setUp() {
        appointmentDAO = new AppointmentDAOImpl();
    }

    @Test
    public void testGetAllAppointmentsNotNull() {
        List<Appointment> list = appointmentDAO.getAllAppointments();
        assertNotNull("Appointments list from DAO should not be null", list);
    }

    @Test
    public void testGetBookedTimesNotNull() {
        List<String> bookedTimes = appointmentDAO.getBookedTimes("Dr. Samantha Perera", Date.valueOf("2026-09-01"));
        assertNotNull("Booked times list from DAO should not be null", bookedTimes);
    }
}
