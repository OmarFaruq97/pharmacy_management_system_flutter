package com.omar.isdb62.pharmacy_management_backend.service;

import com.omar.isdb62.pharmacy_management_backend.model.MedicineName;
import com.omar.isdb62.pharmacy_management_backend.repository.MedicineRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MedicineNameService {

    @Autowired
    private MedicineRepository medicineRepository;


    public List<MedicineName> getAllMedicineNames() {
        return medicineRepository.findAll();
    }

    public MedicineName saveMedicine(MedicineName medicineName) {
        medicineName.setMedicineName(medicineName.getMedicineName());
        return medicineRepository.save(medicineName);
    }

    public void deleteMedicine(Long id) {
        medicineRepository.deleteById(id);
    }
}
