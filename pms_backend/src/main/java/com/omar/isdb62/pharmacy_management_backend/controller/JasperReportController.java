package com.omar.isdb62.pharmacy_management_backend.controller;

import jakarta.servlet.http.HttpServletResponse;
import net.sf.jasperreports.engine.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/reports")
public class JasperReportController {

    @Autowired
    private DataSource dataSource;

    @GetMapping("/invoice-history")
    public void generateInvoiceHistoryReport(HttpServletResponse response) throws Exception {
        ClassPathResource reportResource = new ClassPathResource("report/invoice-history.jrxml");
        InputStream reportStream = reportResource.getInputStream();

        JasperReport jasperReport = JasperCompileManager.compileReport(reportStream);

        try (Connection conn = dataSource.getConnection()) {
            Map<String, Object> parameters = new HashMap<>();
            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parameters, conn);

            response.setContentType(MediaType.APPLICATION_PDF_VALUE);
            response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=invoice-history.pdf");

            JasperExportManager.exportReportToPdfStream(jasperPrint, response.getOutputStream());
        }
    }
}
