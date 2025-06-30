package com.omar.isdb62.pharmacy_management_backend.service;

import com.omar.isdb62.pharmacy_management_backend.model.Inventory;
import com.omar.isdb62.pharmacy_management_backend.repository.InventoryRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class InventoryService {

    private final InventoryRepository inventoryRepository;

    public InventoryService(InventoryRepository inventoryRepository) {
        this.inventoryRepository = inventoryRepository;
    }

    public Inventory saveMedicine(Inventory inventory) {
        return inventoryRepository.save(inventory);
    }

    public List<Inventory> getAllMedicine() {
        return inventoryRepository.findAll();
    }

    public List<Inventory> getMedByName(String name) {
        return inventoryRepository.findAllByItemNameContainingIgnoreCase(name);
    }

    public void deleteMedicineByNameAndCategory(String name, String category) {
        Inventory inventory = inventoryRepository.findByItemNameAndCategory(name, category)
                .orElseThrow(() -> new RuntimeException("Medicine not found with name: " + name + category));
        inventoryRepository.delete(inventory);
    }

    public Inventory updateMedicineByNameAndCategory(String name, String category, Inventory updatedInventory) {
        Inventory inventory = inventoryRepository.findByItemNameAndCategory(name, category)
                .orElseThrow(() -> new RuntimeException("Medicine not found with name: " + name + category));

        inventory.setCategory(updatedInventory.getCategory());
        inventory.setUnitPrice(updatedInventory.getUnitPrice());
        inventory.setPurchaseDiscount(updatedInventory.getPurchaseDiscount());
        inventory.setSellPrice(updatedInventory.getSellPrice());

        return inventoryRepository.save(inventory);
    }

    public List<Inventory> getLowStockMedicines(int threshold) {
        return inventoryRepository.findByQuantityLessThan(threshold);
    }

    // Modified receive logic to update quantity if item exists
    public Inventory receiveMedicine(Inventory newInventory) {
        Optional<Inventory> existing = inventoryRepository.findByItemNameAndCategory(
                newInventory.getItemName(), newInventory.getCategory());

        if (existing.isPresent()) {
            Inventory inventory = existing.get();
            inventory.setQuantity(inventory.getQuantity() + newInventory.getQuantity());
            inventory.setUnitPrice(newInventory.getUnitPrice());
            inventory.setPurchaseDiscount(newInventory.getPurchaseDiscount());
            inventory.setNetPurchasePrice(newInventory.getNetPurchasePrice());
            inventory.setSellPrice(newInventory.getSellPrice());
            inventory.setReceivedDate(LocalDate.now());

            return inventoryRepository.save(inventory);
        } else {
            newInventory.setReceivedDate(LocalDate.now());
            return inventoryRepository.save(newInventory);
        }
    }

    //***Low stock working area start***

    public List<Inventory> getLowStockItems() {
        return inventoryRepository.findByQuantityLessThan(10);
    }

    public List<Inventory> getSufficientStockItems() {
        return inventoryRepository.findByQuantityGreaterThanEqual(10);
    }

    // ** Low stock working area end **
}