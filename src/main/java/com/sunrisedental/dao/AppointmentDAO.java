package com.sunrisedental.dao;

import com.sunrisedental.model.Appointment;
import java.util.List;
import java.util.Map;

public interface AppointmentDAO {
    boolean createAppointment(Appointment app);
    Appointment getAppointmentByNumber(String appointmentNumber);
    List<Appointment> getAllAppointments();
    List<Map<String, Object>> getDentistStatistics();
    List<Map<String, Object>> getDentistStatistics(String filterDate, String filterMonth);
    Map<String, Integer> getAppointmentCounts(String filterDate, String filterMonth);
    boolean updateAppointmentStatus(String appointmentNumber, String status);
    boolean updateAppointmentDetails(Appointment app);
    List<String> getBookedTimes(String dentistName, java.sql.Date appointmentDate);
}
