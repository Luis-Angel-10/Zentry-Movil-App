package zentry.back.api.core.models;
import org.springframework.security.core.GrantedAuthority;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "users", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "username", length = 50)
    private String username;

    @Email
    @Column(name = "email", length = 100)
    private String email;

    
    @Column(name = "password", length = 255)
    private String password;

    @Builder.Default
    @Column(name = "verified", nullable = false, columnDefinition = "boolean default false")
    private Boolean verified = false;

    @Builder.Default
    @Column(name = "onboarding_completed", columnDefinition = "boolean default false")
    private Boolean onboardingCompleted = false;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(); // Sin roles por ahora
    }

    @Override
    public String getPassword() {
        return this.password;
    }

    @Override
    public String getUsername() {
        return this.email;
    }

    /**
     * Nombre de usuario real (distinto del email que exige el contrato de UserDetails).
     * Lombok no genera un getter para el campo "username" porque el override de arriba
     * ya ocupa esa firma, así que este método expone el valor real del campo.
     */
    public String getHandle() {
        return this.username;
    }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return true; }
}
