package com.sunrisedental;

import com.sunrisedental.dao.BillDAO;
import com.sunrisedental.dao.impl.BillDAOImpl;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

import java.util.List;
import java.util.Map;

public class BillDAOTest {

    private BillDAO billDAO;

    @Before
    public void setUp() {
        billDAO = new BillDAOImpl();
    }

    @Test
    public void testGetFinancialSummaryNotNull() {
        Map<String, Object> summary = billDAO.getFinancialSummary();
        assertNotNull("Financial summary map from DAO should not be null", summary);
        assertTrue(summary.containsKey("total_bills"));
        assertTrue(summary.containsKey("total_revenue"));
    }

    @Test
    public void testGetTreatmentRevenueReportNotNull() {
        List<Map<String, Object>> report = billDAO.getTreatmentRevenueReport();
        assertNotNull("Treatment revenue report list from DAO should not be null", report);
    }
}
