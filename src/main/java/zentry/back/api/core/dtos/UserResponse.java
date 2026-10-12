package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserResponse {

    private Integer id;
    private String token;
    private String username;
    private String email;
    private String message;
    private Boolean requiresVerification;
}
