package zentry.back.api.core.dtos;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VerifyLoginRequest {
    @NotBlank
    @Email
    private String email;

    @NotBlank
    private String code;
}
