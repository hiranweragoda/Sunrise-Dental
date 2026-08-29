package com.sunrisedental;

import org.junit.Test;
import static org.junit.Assert.*;

import java.security.MessageDigest;

public class SecurityPasswordHashTest {

    @Test
    public void testSHA256PasswordHashLength() throws Exception {
        String rawPassword = "admin123";
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(rawPassword.getBytes());

        StringBuilder hexString = new StringBuilder();
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }

        String hashedPassword = hexString.toString();

        assertNotNull(hashedPassword);
        assertEquals(64, hashedPassword.length()); // SHA-256 hex string is always 64 characters long
    }
}
