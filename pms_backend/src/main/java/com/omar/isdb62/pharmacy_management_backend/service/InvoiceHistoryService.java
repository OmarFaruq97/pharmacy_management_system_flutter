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
    public InvoiceHistory createInvoice(InvoiceHistory invoice) {
        invoice.setInvoiceNumber(generateInvoiceNumber());
        invoice.setDate(LocalDate.now());

        //  Find the matching inventory by itemName and category
        Inventory inventory = inventoryRepository.findByItemNameAndCategory(
                invoice.getItemName(),
                invoice.getCategory()  // If "strength" now means "category"
        ).orElseThrow(() -> new RuntimeException("Inventory item not found for invoice."));

        // Check if enough quantity exists
        if (inventory.getQuantity() < invoice.getQuantity()) {
            throw new RuntimeException("Not enough stock to complete the sale.");
        }

        //  Reduce inventory quantity
        inventory.setQuantity(inventory.getQuantity() - invoice.getQuantity());

        //  Save the updated inventory
        inventoryRepository.save(inventory);

        // Save invoice record
        return invoiceHistoryRepository.save(invoice);
    }

    public InvoiceHistory updateInvoiceByInvoiceNumber(String invoiceNumber, InvoiceHistory updatedInvoice) {
        InvoiceHistory invoice = invoiceHistoryRepository.findByInvoiceNumber(invoiceNumber)
                .orElseThrow(() -> new RuntimeException("Invoice not found with number: " + invoiceNumber));

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
        invoice.setDate(LocalDate.now()); // set current date when creating invoice


        return invoiceHistoryRepository.save(invoice);
    }

    public void deleteByInvoiceNumber(String invoiceNumber) {
        InvoiceHistory invoice = invoiceHistoryRepository.findByInvoiceNumber(invoiceNumber)
                .orElseThrow(() -> new RuntimeException("Invoice not found with number: " + invoiceNumber));
        invoiceHistoryRepository.delete(invoice);
    }

    public List<InvoiceHistory> getAllInvoiceHistories() {
        return invoiceHistoryRepository.findAll();
    }

    public InvoiceHistory getByInvoiceNumber(String invoiceNumber) {
        return invoiceHistoryRepository.findByInvoiceNumber(invoiceNumber)
                .orElseThrow(() -> new RuntimeException("Invoice not found with number: " + invoiceNumber));
    }

    public List<InvoiceHistory> getTodaySales() {
        return invoiceHistoryRepository.findByDate(LocalDate.now());
    }

}