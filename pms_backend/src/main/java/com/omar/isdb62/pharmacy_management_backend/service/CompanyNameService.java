package com.omar.isdb62.pharmacy_management_backend.service;

import com.omar.isdb62.pharmacy_management_backend.model.CompanyName;
import com.omar.isdb62.pharmacy_management_backend.repository.CompanyNameRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CompanyNameService {

    @Autowired
    private CompanyNameRepository companyNameRepository;

    public List<CompanyName> getAllCompanies() {
        return companyNameRepository.findAll();
    }

    public CompanyName saveCompany(CompanyName companyName) {
        companyName.setCompanyName(companyName.getCompanyName());
        return companyNameRepository.save(companyName);
    }

    public void deleteCompany(Long id) {
        companyNameRepository.deleteById(id);
    }
}
