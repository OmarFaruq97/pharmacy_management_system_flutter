package com.omar.isdb62.pharmacy_management_backend.controller;


import com.omar.isdb62.pharmacy_management_backend.configaration.JwtTokenProvider;
import com.omar.isdb62.pharmacy_management_backend.dto.LoginRequest;
import com.omar.isdb62.pharmacy_management_backend.dto.RegisterRequest;
import com.omar.isdb62.pharmacy_management_backend.dto.UserResponse;
import com.omar.isdb62.pharmacy_management_backend.model.CustomUserDetails;
import com.omar.isdb62.pharmacy_management_backend.model.User;
import com.omar.isdb62.pharmacy_management_backend.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@CrossOrigin
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserService userService;

    // Constructor injection for required services
    public AuthController(AuthenticationManager authenticationManager,
                          JwtTokenProvider jwtTokenProvider,
                          UserService userService) {
        this.authenticationManager = authenticationManager;
        this.jwtTokenProvider = jwtTokenProvider;
        this.userService = userService;
    }

    // ========== REGISTER USER ==========
    // Endpoint for user registration (Admin or Pharmacist)
    @PostMapping("/register")
//    @PreAuthorize("hasRole('ADMIN')") // Only Admins can create users
    public ResponseEntity<?> registerUser(@Valid @RequestBody RegisterRequest registerRequest) {
        try {
            // Create a new User object from request data
            User user = new User(
                    registerRequest.email(),
                    registerRequest.password(),
                    registerRequest.role(),    // e.g., ROLE_ADMIN or ROLE_PHARMACIST
                    registerRequest.firstName(),
                    registerRequest.lastName(),
                    registerRequest.phoneNumber(),
                    registerRequest.salary()
            );

            // Save the user using the service layer
            User savedUser = userService.createUser(user);

            // Prepare a response DTO (excluding password!)
            UserResponse userResponse = new UserResponse();
            userResponse.setId(savedUser.getId());
            userResponse.setEmail(savedUser.getEmail());
            userResponse.setRole(savedUser.getRole());
            userResponse.setFirstName(savedUser.getFirstName());
            userResponse.setLastName(savedUser.getLastName());
            userResponse.setPhoneNumber(savedUser.getPhoneNumber());
            userResponse.setSalary(savedUser.getSalary());

            return ResponseEntity.status(HttpStatus.CREATED).body(userResponse);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ========== LOGIN USER ==========
    // Endpoint for user login
    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(HttpServletRequest request,
                                              HttpServletResponse response,
                                              @Valid @RequestBody LoginRequest loginRequest) {
        try {
            // Try to authenticate the user with email and password
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.email(),
                            loginRequest.password()
                    )
            );

            // Set the authentication in security context
            SecurityContextHolder.getContext().setAuthentication(authentication);

            // Generate JWT token using authentication info
            String jwt = jwtTokenProvider.createToken(authentication);

            // Get user details from authenticated principal
            CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
            User user = userDetails.user();

            //Prepare response with token and user info
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("access_token", jwt);
            responseData.put("tokenType", "Bearer");

            //Add user-specific info
            Map<String, Object> userData = new HashMap<>();
            userData.put("id", user.getId());
            userData.put("email", user.getEmail());
            userData.put("role", user.getRole());
            userData.put("firstName", user.getFirstName());
            userData.put("lastName", user.getLastName());
            userData.put("salary", user.getSalary());

            responseData.put("user", userData);

            return ResponseEntity.ok(responseData);
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Invalid username or password");
        }
    }

    // ========== VALIDATE TOKEN ==========
    @GetMapping("/validate-token")
    public ResponseEntity<?> validateToken(HttpServletRequest request) {
        //Extract token from Authorization header
        String jwt = getJwtFromRequest(request);

        //Validate the token
        if (jwt != null && jwtTokenProvider.validateToken(jwt)) {
            //  Get email instead of username from token (we use email as subject)
            String email = jwtTokenProvider.getEmailFromToken(jwt);

            //  Load user details by email (your CustomUserDetailsService should support this)
            UserDetails userDetails = userService.loadUserByUsername(email); // ❗You may want to rename this method to `loadUserByEmail` for clarity

            //  Cast to CustomUserDetails to access your custom fields
            CustomUserDetails customUserDetails = (CustomUserDetails) userDetails;
            User user = customUserDetails.user(); // Assuming you return `User` from your wrapper

            //  Build user response object
            UserResponse userResponse = new UserResponse();
            userResponse.setId(user.getId());
            userResponse.setEmail(user.getEmail());
            userResponse.setRole(user.getRole());
            userResponse.setFirstName(user.getFirstName());
            userResponse.setLastName(user.getLastName());
            userResponse.setSalary(userResponse.getSalary());

            return ResponseEntity.ok(userResponse);
        }

        //  If token is invalid or missing
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid or expired token");
    }


    //========== HELPER METHOD: Extract JWT token from request ==========
    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        //Token should be in format: "Bearer {token}"

        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer")) {
            return bearerToken.substring(7); // remove "Bearer " prefix
        }
        return null;
    }
}