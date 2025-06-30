package com.omar.isdb62.pharmacy_management_backend.dto;

public record UserCreateRequest(
        String username,
        String email,
        String password,

        String role,

        String firstName,
        String lastName,
        String phoneNumber,
        Long salary
) {
}
