package com.omar.isdb62.pharmacy_management_backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PasswordChangeRequest(

        @NotBlank(message = "Current Password can not be blank")
        String currentPassword,

        @NotBlank(message = "New password cannot be blank")
        @Size (min = 4, message = "New password must be at least 4 character")
        String newPassword
) {
}
