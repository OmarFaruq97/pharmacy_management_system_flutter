package com.omar.isdb62.pharmacy_management_backend.controller;

import com.omar.isdb62.pharmacy_management_backend.model.MedicineName;
import com.omar.isdb62.pharmacy_management_backend.service.MedicineNameService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/medicine-name")
public class MedicineController {
    @Autowired
    private MedicineNameService medicineNameService;

    @GetMapping
    public List<MedicineName> getAllMedicineNames() {
        return medicineNameService.getAllMedicineNames();
    }

    @PostMapping
    public MedicineName add(@RequestBody MedicineName medicineName) {
        return medicineNameService.saveMedicine(medicineName);
    }

    @DeleteMapping("/{id}")
    public void deleteMedicine(@PathVariable Long id) {
        medicineNameService.deleteMedicine(id);
    }

}
