package zentry.back.api.core.dtos;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class RegisterRequest {
    
    @NotBlank
    private String username;

    @NotBlank
    @Email
    private String email;
    
    @NotBlank
    private String password;
}