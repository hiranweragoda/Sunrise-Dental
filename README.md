# Sunrise Dental Clinic Management System (MVC Web Application)

An enterprise-grade, distributed 3-Tier Web Application for **Sunrise Dental Clinic**, built using Java EE Servlets, JSP, JavaBeans, and MySQL.

---

## 🌟 Key Features

* **Role-Based Authentication (RBAC):** Distinct dashboards and capabilities for **Clinical Staff** and **System Administrators**.
* **BCrypt Password Security:** Adaptive salted password hashing (`$2a$10$...`) protecting user credentials.
* **Patient Registration:** Auto-generated unique patient identification codes (`PAT-0001` format) supporting adult and child registrations.
* **Interactive Live Slot Engine:** Real-time doctor availability check preventing double-booking and concurrent scheduling conflicts.
* **Automated Invoicing & Atomic Billing:** Powered by the MySQL Stored Procedure `GenerateBill` for 100% calculation accuracy.
* **Printable Thermal / A4 Receipts:** Formatted invoice receipts with treatment cost and consultation breakdowns.
* **Visual Analytics & Reporting:** Interactive Chart.js graphs for operational revenue analysis and one-click CSV export.

---

## 🏛️ Architecture & Design Patterns

1. **3-Tier Architecture:**
   * **Presentation Tier:** JSP, CSS3, JavaScript, Chart.js (`webapp/`).
   * **Business Logic Tier:** Java Servlets (`AppointmentServlet`, `PatientServlet`, `BillServlet`, `AuthServlet`).
   * **Data Persistence Tier:** MySQL Database (`sunrise_dental`), JavaBeans Entity Models, and Data Access Objects (DAOs).

2. **Design Patterns Implemented:**
   * **Singleton Pattern:** `DBConnection.java` for centralized, resource-efficient connection management.
   * **Data Access Object (DAO) Pattern:** Decoupling SQL persistence logic from HTTP controllers.
   * **Model-View-Controller (MVC) Pattern:** Strict separation of data, display views, and application workflow.
   * **Front Controller / Security Filter Pattern:** `AuthFilter.java` for centralized session verification.
   * **Data Transfer Object (DTO) Pattern:** `Bill.java` and `Patient.java` for secure inter-tier data encapsulation.

---

## 🛠️ Technology Stack

* **Backend:** Java 11 / Java EE (Servlets 4.0, JSP 2.3, JSTL)
* **Frontend:** HTML5, CSS3, Vanilla JavaScript, Chart.js
* **Database:** MySQL 8.0 (InnoDB, Stored Procedures, Foreign Key Constraints)
* **Build Tool:** Apache Maven
* **Security & Utilities:** jBCrypt, Google Gson
