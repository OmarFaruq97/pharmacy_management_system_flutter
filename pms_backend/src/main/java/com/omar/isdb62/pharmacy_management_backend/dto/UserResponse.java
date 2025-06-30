package com.omar.isdb62.pharmacy_management_backend.dto;

import com.omar.isdb62.pharmacy_management_backend.constants.Role;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class UserResponse {

    private Long id;

    private String email;
    private String role;

    private String firstName;
    private String lastName;
    private String phoneNumber;
    private Long salary;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

}
