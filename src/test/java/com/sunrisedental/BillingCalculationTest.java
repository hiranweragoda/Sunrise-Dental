package com.sunrisedental;

import org.junit.Test;
import static org.junit.Assert.*;

import java.math.BigDecimal;

public class BillingCalculationTest {

    @Test
    public void testTotalCostCalculation() {
        BigDecimal treatmentCost = new BigDecimal("5000.00");
        BigDecimal consultationFee = new BigDecimal("2500.00");
        
        BigDecimal expectedTotal = treatmentCost.add(consultationFee);
        
        assertEquals(new BigDecimal("7500.00"), expectedTotal);
    }

    @Test
    public void testBalanceCalculation() {
        BigDecimal totalCost = new BigDecimal("7500.00");
        BigDecimal cashGiven = new BigDecimal("10000.00");
        
        BigDecimal expectedBalance = cashGiven.subtract(totalCost);
        
        assertEquals(new BigDecimal("2500.00"), expectedBalance);
    }

    @Test
    public void testZeroConsultationFeeCalculation() {
        BigDecimal treatmentCost = new BigDecimal("4500.00");
        BigDecimal consultationFee = BigDecimal.ZERO;
        
        BigDecimal expectedTotal = treatmentCost.add(consultationFee);
        
        assertEquals(new BigDecimal("4500.00"), expectedTotal);
    }
}
