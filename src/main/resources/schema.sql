-- Create database if not exists
CREATE DATABASE IF NOT EXISTS sunrise_dental;
USE sunrise_dental;

-- Drop existing elements if they exist to allow clean re-runs
DROP TRIGGER IF EXISTS after_appointment_insert;
DROP PROCEDURE IF EXISTS GenerateBill;
DROP TABLE IF EXISTS bills;
DROP TABLE IF EXISTS appointment_audit;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS treatments;
DROP TABLE IF EXISTS users;

-- 1. Users Table for Authentication
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(64) NOT NULL, -- SHA-256 hash of password
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'Staff'
);

-- Seed default user: credentials are 'admin' / 'admin123'
-- SHA-256 for 'admin123' is '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'
INSERT INTO users (username, password_hash, full_name, role) VALUES 
('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Sunrise Admin', 'Admin'),
('staff', '10176e7b7b24d317acfcf8d2064cfd2f24e154f7b5a96603077d5ef813d6a6b6', 'Clinical Staff Member', 'Staff');

-- 2. Treatments Table
CREATE TABLE IF NOT EXISTS treatments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    treatment_name VARCHAR(100) UNIQUE NOT NULL,
    cost DECIMAL(10, 2) NOT NULL
);

-- Seed default treatments
INSERT INTO treatments (treatment_name, cost) VALUES 
('Dental Cleaning & Scaling', 5000.00),
('Composite Filling', 8000.00),
('Tooth Extraction', 6000.00),
('Root Canal Therapy', 45000.00),
('Teeth Whitening', 25000.00),
('Braces Consultation', 3000.00)
ON DUPLICATE KEY UPDATE cost = VALUES(cost);

-- 3. Dentists Table
CREATE TABLE IF NOT EXISTS dentists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dentist_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    contact_number VARCHAR(20)
);

-- Seed default dentists
INSERT INTO dentists (dentist_name, specialization, contact_number) VALUES
('Dr. Samantha Perera', 'Orthodontist', '0771112233'),
('Dr. Nishantha Silva', 'General Dentist', '0772223344'),
('Dr. Priyanga Alwis', 'Pediatric Dentist', '0773334455'),
('Dr. Shalini Fernando', 'Periodontist', '0774445566')
ON DUPLICATE KEY UPDATE specialization = VALUES(specialization);

-- 4. Patients Table
CREATE TABLE IF NOT EXISTS patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    patient_id VARCHAR(50) UNIQUE NOT NULL,
    address VARCHAR(255),
    phone_number VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Appointments Table
CREATE TABLE appointments (
    appointment_number VARCHAR(50) PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    contact_number VARCHAR(20) NOT NULL,
    dentist_name VARCHAR(100) NOT NULL,
    treatment_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'Scheduled',
    FOREIGN KEY (treatment_id) REFERENCES treatments(id)
);

-- 4. Bills Table (Unified Billing & Payment Record)
CREATE TABLE bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_number VARCHAR(50) NOT NULL,
    treatment_cost DECIMAL(10, 2) NOT NULL,
    consultation_fee DECIMAL(10, 2) NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(20) DEFAULT 'Cash',
    cash_given DECIMAL(10, 2),
    balance_returned DECIMAL(10, 2),
    bill_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status VARCHAR(20) DEFAULT 'Paid',
    FOREIGN KEY (appointment_number) REFERENCES appointments(appointment_number) ON DELETE CASCADE
);

-- 7. Stored Procedure to calculate and generate a bill
DELIMITER //
CREATE PROCEDURE GenerateBill(
    IN in_appointment_number VARCHAR(50),
    IN in_consultation_fee DECIMAL(10, 2),
    OUT out_bill_id INT,
    OUT out_total_cost DECIMAL(10, 2)
)
BEGIN
    DECLARE v_treatment_cost DECIMAL(10, 2);
    DECLARE v_treatment_id INT;

    -- Find treatment_id for this appointment
    SELECT treatment_id INTO v_treatment_id
    FROM appointments
    WHERE appointment_number = in_appointment_number;

    -- Get cost from treatments table
    SELECT cost INTO v_treatment_cost
    FROM treatments
    WHERE id = v_treatment_id;

    -- Calculate total cost
    SET out_total_cost = v_treatment_cost + in_consultation_fee;

    -- Insert into bills table
    INSERT INTO bills (appointment_number, consultation_fee, total_cost, payment_status)
    VALUES (in_appointment_number, in_consultation_fee, out_total_cost, 'Paid')
    ON DUPLICATE KEY UPDATE 
        consultation_fee = in_consultation_fee,
        total_cost = out_total_cost,
        payment_status = 'Paid';

    -- Retrieve the last insert/update ID
    SELECT bill_id INTO out_bill_id FROM bills WHERE appointment_number = in_appointment_number;
END;
//
DELIMITER ;
