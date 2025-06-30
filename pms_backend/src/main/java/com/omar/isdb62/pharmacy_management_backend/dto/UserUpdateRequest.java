package com.omar.isdb62.pharmacy_management_backend.dto;

import jakarta.validation.constraints.Email;

public record UserUpdateRequest(

        @Email(message = "Email should be valid")
        String email,

        String role,

        String firstName,
        String lastName,
        String phoneNumber,
        int salary
) {
}
