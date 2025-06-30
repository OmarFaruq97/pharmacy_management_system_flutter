package com.omar.isdb62.pharmacy_management_backend.model;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@Getter
public class JwtUserDetails implements UserDetails {
    private final Long id;
    private final String email; // Use email as username
    private final String role;
    private final Collection<? extends GrantedAuthority> authorities;

    public JwtUserDetails(Long id, String email, String role) {
        this.id = id;
        this.email = email;
        this.role = role;
        this.authorities = Collections.singletonList(
                new SimpleGrantedAuthority("ROLE_" + role)
        );
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    // No password needed for token-based authentication
    @Override
    public String getPassword() {
        return null;
    }

    // Spring Security uses this method to get the login identity
    @Override
    public String getUsername() {
        return email; // Return email as username
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}
