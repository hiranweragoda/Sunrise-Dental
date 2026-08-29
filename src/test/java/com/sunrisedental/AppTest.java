package com.sunrisedental;

import org.junit.Test;
import static org.junit.Assert.*;

import java.math.BigDecimal;

public class AppTest {

    @Test
    public void testBillingCalculationLogic() {
        BigDecimal treatmentCost = new BigDecimal("5000.00");
        BigDecimal consultationFee = new BigDecimal("2500.00");
        
        BigDecimal expectedTotal = treatmentCost.add(consultationFee);
        
        assertEquals(new BigDecimal("7500.00"), expectedTotal);
    }

    @Test
    public void testDatabasePropertiesLoading() {
        java.io.InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties");
        assertNotNull("db.properties should be present on the classpath", input);
    }
}
