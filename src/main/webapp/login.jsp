<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Secure MVC login portal for Sunrise Dental Clinic Appointment and Patient Management System.">
    <title>Login - Sunrise Dental Clinic Management</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="login-body">

    <!-- Decorative Blurred Background Elements -->
    <div class="bg-decor decor-1"></div>
    <div class="bg-decor decor-2"></div>

    <main class="login-card">
        <div class="login-header">
            <div class="login-logo">
                <span class="logo-icon">🦷</span>
                <span class="logo-text">Sunrise Dental</span>
            </div>
            <h1 class="login-title">Staff & Admin Portal</h1>
            <p class="login-subtitle">Please enter your credentials to login</p>
        </div>

        <!-- Alert Notification Box for Server-Side Error Messages -->
        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
            <div class="alert alert-error" style="display: flex;">
                <span>⚠️</span>
                <span><%= error %></span>
            </div>
        <% } %>

        <!-- Standard HTML Form POST to login-action servlet -->
        <form id="login-form" action="login-action" method="POST">
            <div class="form-grid" style="display: flex; flex-direction: column; gap: 1.25rem;">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" placeholder="e.g. admin" required autocomplete="username">
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="••••••••" required autocomplete="current-password">
                </div>

                <button type="submit" id="btn-login" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">
                    Secure Login
                </button>
            </div>
        </form>
    </main>

</body>
</html>
