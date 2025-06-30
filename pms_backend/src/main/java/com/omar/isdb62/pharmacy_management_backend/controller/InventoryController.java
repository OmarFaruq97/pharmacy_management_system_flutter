package com.omar.isdb62.pharmacy_management_backend.controller;

import com.omar.isdb62.pharmacy_management_backend.model.Inventory;
import com.omar.isdb62.pharmacy_management_backend.repository.InventoryRepository;
import com.omar.isdb62.pharmacy_management_backend.service.InventoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("api/inventory")
public class InventoryController {

    @Autowired
    private InventoryService inventoryService;

    @GetMapping("/all")
    public List<Inventory> getAllMedicine() {
        return inventoryService.getAllMedicine();
    }

    @GetMapping("/search")
    public List<Inventory> getMedByName(@RequestParam String name) {
        return inventoryService.getMedByName(name);
    }


    @PostMapping("/receive")
    public ResponseEntity<Inventory> receiveMedicine(@RequestBody Inventory inventory) {
        Inventory saved = inventoryService.receiveMedicine(inventory); // This uses your accumulation logic
        return ResponseEntity.ok(saved);
    }


    @DeleteMapping("/delete-by-name-and-category")
    public ResponseEntity<String> deleteByNameAndCategory(@RequestParam String name,
                                                          @RequestParam String category) {
        inventoryService.deleteMedicineByNameAndCategory(name, category);
        return ResponseEntity.ok(name + category + " deleted successfully");
    }


    @PutMapping("/update-by-name-and-category")
    public ResponseEntity<Inventory> updateMedicineByNameAndStrength(@RequestParam String name, @RequestParam String category, @RequestBody Inventory updatedInventory) {
        Inventory updated = inventoryService.updateMedicineByNameAndCategory(name, category, updatedInventory);
        return ResponseEntity.ok(updated);
    }

    //***Low stock working area start***

    @GetMapping("/low-stock")
    public ResponseEntity<List<Inventory>> getLowStockItems() {
        return ResponseEntity.ok(inventoryService.getLowStockItems());
    }

    @GetMapping("/sufficient-stock")
    public ResponseEntity<List<Inventory>> getSufficientStockItems() {
        return ResponseEntity.ok(inventoryService.getSufficientStockItems());
    }

    // ** Low stock working area end **

    @Autowired
    private InventoryRepository inventoryRepository;

    @GetMapping("/daily-receives")
    public List<Inventory> getTodayReceivedMedicines() {
        return inventoryRepository.findByReceivedDate(LocalDate.now());
    }


}