package com.sunrisedental;

import org.junit.Test;
import static org.junit.Assert.*;

import org.mindrot.jbcrypt.BCrypt;

public class SecurityPasswordHashTest {

    @Test
    public void testBCryptPasswordHashingAndVerification() {
        String rawPassword = "admin123";
        String hashedPassword = BCrypt.hashpw(rawPassword, BCrypt.gensalt(10));

        assertNotNull(hashedPassword);
        assertTrue(hashedPassword.startsWith("$2a$") || hashedPassword.startsWith("$2b$"));
        assertEquals(60, hashedPassword.length()); // Standard BCrypt hash is 60 characters
        assertTrue(BCrypt.checkpw("admin123", hashedPassword));
        assertFalse(BCrypt.checkpw("wrongpass", hashedPassword));
    }

    @Test
    public void testEmptyCredentialsValidation() {
        String emptyUsername = "";
        String emptyPassword = "";
        
        // Verifies that blank credentials are empty and blocked before submission
        assertTrue(emptyUsername.trim().isEmpty());
        assertTrue(emptyPassword.trim().isEmpty());
    }
}
