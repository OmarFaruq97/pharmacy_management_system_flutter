package com.omar.isdb62.pharmacy_management_backend.controller;

import com.omar.isdb62.pharmacy_management_backend.model.CompanyName;
import com.omar.isdb62.pharmacy_management_backend.service.CompanyNameService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/company-name")
public class CompanyNameController {
    @Autowired
    private CompanyNameService companyNameService;

    @GetMapping
    public List<CompanyName> getAllCompanies() {
        return companyNameService.getAllCompanies();
    }

    @PostMapping
    public CompanyName createCompany(@RequestBody CompanyName companyName) {
        return companyNameService.saveCompany(companyName);
    }

    @DeleteMapping("/{id}")
    public void deleteCompany(@PathVariable Long id) {
        companyNameService.deleteCompany(id);
    }
}
