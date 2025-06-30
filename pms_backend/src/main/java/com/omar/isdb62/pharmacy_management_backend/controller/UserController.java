package com.omar.isdb62.pharmacy_management_backend.controller;

import com.omar.isdb62.pharmacy_management_backend.annotation.CurrentUser;
import com.omar.isdb62.pharmacy_management_backend.constants.Role;
import com.omar.isdb62.pharmacy_management_backend.dto.PasswordChangeRequest;
import com.omar.isdb62.pharmacy_management_backend.dto.UserCreateRequest;
import com.omar.isdb62.pharmacy_management_backend.dto.UserResponse;
import com.omar.isdb62.pharmacy_management_backend.dto.UserUpdateRequest;
import com.omar.isdb62.pharmacy_management_backend.model.User;
import com.omar.isdb62.pharmacy_management_backend.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
@CrossOrigin("http://localhost:4200")
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    //Return the current logged-in user
    @GetMapping("/user")
    public UserDetails user(@CurrentUser UserDetails currentUser) {
        return currentUser;
    }


    //Only ADMIN can view all users
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public List<UserResponse> getAllUsers() {
        return userService.getAllUsers().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    //ADMIN or the user himself can view a specific user by ID
    @GetMapping("/{id}")
    // Allow access if the user is an ADMIN or accessing their own user ID
    @PreAuthorize("hasRole('ADMIN') or @userSecurity.hasUserId(authentication, #id)")
    public ResponseEntity<UserResponse> getUsersById(@PathVariable Long id) {
        return userService.getUserById(id)
                .map(user -> ResponseEntity.ok(convertToDTO(user)))
                .orElse(ResponseEntity.notFound().build());
    }

    //ADMIN can view users by role
    @GetMapping("/role/{role}")
    @PreAuthorize("hasRole('ADMIN')")
    public List<UserResponse> getUsersByRole(@PathVariable Role role) {
        return userService.getUsersByRole(role).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }


    //Only ADMIN can create new users
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody UserCreateRequest userCreateRequest) {
        User user = new User(
                userCreateRequest.email(),
                userCreateRequest.password(),

                userCreateRequest.role(),

                userCreateRequest.firstName(),
                userCreateRequest.lastName(),
                userCreateRequest.phoneNumber(),
                userCreateRequest.salary()
        );

        User createdUser = userService.createUser(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(convertToDTO(createdUser));
    }

    //ADMIN or the user himself can update user
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or @userSecurity.hasUserId(authentication, #id)")
    public ResponseEntity<UserResponse>
    updateUser(@PathVariable Long id, @Valid @RequestBody UserUpdateRequest userUpdateRequest) {
        try {
            User userDetails = new User();

            userDetails.setFirstName(userUpdateRequest.firstName());
            userDetails.setLastName(userUpdateRequest.lastName());

            userDetails.setEmail(userUpdateRequest.email());
            userDetails.setPhoneNumber(userUpdateRequest.phoneNumber());

            //Only admin can update roles
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"))) {
                userDetails.setRole(userUpdateRequest.role());
            }

            User updateUser = userService.updateUser(id, userDetails);

            return ResponseEntity.ok(convertToDTO(updateUser));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    //Only ADMIN can delete users
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        try {
            userService.deleteUser(id);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    //Return the currently authenticated user's info
    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(Authentication authentication) {
        User currentUser = userService.getCurrentUser(authentication);
        if (currentUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.ok(convertToDTO(currentUser));
    }

    //Allow a user to change their password
    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword
    (Authentication authentication, @Valid @RequestBody PasswordChangeRequest request) {
        try {
            User currentUser = userService.getCurrentUser(authentication);
            if (currentUser == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }

            userService.changePassword(currentUser.getId(),
                    request.currentPassword(),
                    request.newPassword());

            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    //Convert user entity to UserResponse DTO
    // Helper method to convert User entity to UserDTO (this method create as solve error)
    private UserResponse convertToDTO(User user) {
        UserResponse dto = new UserResponse();

        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setRole(user.getRole());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setPhoneNumber(user.getPhoneNumber());
        dto.setSalary(user.getSalary());


        dto.setCreatedAt(user.getCreateAt());
        dto.setUpdatedAt(user.getUpdateAt());

        return dto;
    }
}