package com.omar.isdb62.pharmacy_management_backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UserRegisterRequest(

        @NotBlank(message = "email can't be blank")
        @Email(message = "email must be valid")
        String email,

        @NotBlank(message = "password can't be blank")
        @Size(min = 5, message = "password must be at least 5 characters")
        String password,

        String role,

        String firstName,
        String lastName,
        String phoneNumber,
        int salary

) {
}
