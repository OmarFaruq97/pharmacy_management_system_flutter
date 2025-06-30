package com.omar.isdb62.pharmacy_management_backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "pms_invoice_history")
public class InvoiceHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    //1
    @Column(name = "invoice_number")
    private String invoiceNumber;

    //2
    @Column(name = "customer_name")
    private String customerName;

    //3
    @Column(name = "contact_number")
    private String contactNumber;

    //4
    @Column(name = "item_name")
    private String itemName;

    //5
    @Column(name = "category")
    private String category;

    //6
    private int quantity;

    //7
    @Column(name = "unit_price")
    private double unitPrice;

    //8
    @Column(name = "sub_total")
    private double subTotal;

    //9
    private double amount;

    //10
    private double discount;

    //11
    @Column(name = "discount_amount")
    private double discountAmount;

    //12
    @Column(name = "net_payable")
    private double netPayable;

    //13
    @Column(name = "date")
    private LocalDate date;  // Add this field

}
