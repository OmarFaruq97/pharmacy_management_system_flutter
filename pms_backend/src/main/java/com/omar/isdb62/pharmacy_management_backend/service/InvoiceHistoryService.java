package com.omar.isdb62.pharmacy_management_backend.service;

import com.omar.isdb62.pharmacy_management_backend.model.InvoiceHistory;
import com.omar.isdb62.pharmacy_management_backend.model.Inventory;
import com.omar.isdb62.pharmacy_management_backend.repository.InvoiceHistoryRepository;
import com.omar.isdb62.pharmacy_management_backend.repository.InventoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.Date;
import java.util.List;

@Service
public class InvoiceHistoryService {
    @Autowired
    private InvoiceHistoryRepository invoiceHistoryRepository;

    @Autowired
    private InventoryRepository inventoryRepository;

    // Generate invoice number
    public String generateInvoiceNumber() {
        String datePrefix = new SimpleDateFormat("yyyyMMdd").format(new Date());
        String prefix = "INV-" + datePrefix;
        int count = invoiceHistoryRepository.countByInvoiceNumberStartingWith(prefix) + 1;
        return String.format("%s-%04d", prefix, count);
    }

    // Create invoice and update inventory
//    public InvoiceHistory createInvoice(InvoiceHistory invoice) {
//        invoice.setInvoiceNumber(generateInvoiceNumber());
//        invoice.setDate(LocalDate.now());
//
//        //  Find the matching inventory by itemName and category
//        Inventory inventory = inventoryRepository.findByItemNameAndCategory(
//                invoice.getItemName(),
//                invoice.getCategory()  // If "strength" now means "category"
//        ).orElseThrow(() -> new RuntimeException("Inventory item not found for invoice."));
//
//        // Check if enough quantity exists
//        if (inventory.getQuantity() < invoice.getQuantity()) {
//            throw new RuntimeException("Not enough stock to complete the sale.");
//        }
//
//        //  Reduce inventory quantity
//        inventory.setQuantity(inventory.getQuantity() - invoice.getQuantity());
//
//        //  Save the updated inventory
//        inventoryRepository.save(inventory);
//
//        // Save invoice record
//        return invoiceHistoryRepository.save(invoice);
//    }

    public List<InvoiceHistory> createInvoices(List<InvoiceHistory> invoices) {
        String invoiceNumber = generateInvoiceNumber(); // Same number for all

        for (InvoiceHistory invoice : invoices) {
            invoice.setInvoiceNumber(invoiceNumber);
            invoice.setDate(LocalDate.now());

            Inventory inventory = inventoryRepository.findByItemNameAndCategory(
                            invoice.getItemName(), invoice.getCategory())
                    .orElseThrow(() -> new RuntimeException("Inventory item not found."));

            if (inventory.getQuantity() < invoice.getQuantity()) {
                throw new RuntimeException("Not enough stock.");
            }

            inventory.setQuantity(inventory.getQuantity() - invoice.getQuantity());
            inventoryRepository.save(inventory);
        }

        return invoiceHistoryRepository.saveAll(invoices);
    }


    public InvoiceHistory updateInvoiceByInvoiceNumber(String invoiceNumber, InvoiceHistory updatedInvoice) {
        List<InvoiceHistory> invoices = invoiceHistoryRepository.findByInvoiceNumber(invoiceNumber);

        if (invoices.isEmpty()) {
            throw new RuntimeException("Invoice not found with number: " + invoiceNumber);
        }

        // Update only the first invoice entry (or loop through all if needed)
        InvoiceHistory invoice = invoices.get(0); // Assuming you're updating the first one only

        invoice.setCustomerName(updatedInvoice.getCustomerName());
        invoice.setContactNumber(updatedInvoice.getContactNumber());
        invoice.setItemName(updatedInvoice.getItemName());
        invoice.setQuantity(updatedInvoice.getQuantity());
        invoice.setUnitPrice(updatedInvoice.getUnitPrice());
        invoice.setSubTotal(updatedInvoice.getSubTotal());
        invoice.setAmount(updatedInvoice.getAmount());
        invoice.setDiscount(updatedInvoice.getDiscount());
        invoice.setDiscountAmount(updatedInvoice.getDiscountAmount());
        invoice.setNetPayable(updatedInvoice.getNetPayable());
        invoice.setDate(LocalDate.now());

        return invoiceHistoryRepository.save(invoice);
    }


    public void deleteByInvoiceNumber(String invoiceNumber) {
        List<InvoiceHistory> invoices = invoiceHistoryRepository.findByInvoiceNumber(invoiceNumber);
        if (invoices.isEmpty()) {
            throw new RuntimeException("Invoice not found with number: " + invoiceNumber);
        }
        invoiceHistoryRepository.deleteAll(invoices);
    }

    public List<InvoiceHistory> getAllInvoiceHistories() {
        return invoiceHistoryRepository.findAll();
    }

    public List<InvoiceHistory> getByInvoiceNumber(String invoiceNumber) {
        List<InvoiceHistory> invoices = invoiceHistoryRepository.findByInvoiceNumber(invoiceNumber);
        if (invoices.isEmpty()) {
            throw new RuntimeException("Invoice not found with number: " + invoiceNumber);
        }
        return invoices;
    }



    public List<InvoiceHistory> getTodaySales() {
        return invoiceHistoryRepository.findByDate(LocalDate.now());
    }

}