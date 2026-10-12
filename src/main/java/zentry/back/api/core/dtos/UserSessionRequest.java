package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserSessionRequest {

    @NotNull
    private Integer userId;

    private String token;
}
