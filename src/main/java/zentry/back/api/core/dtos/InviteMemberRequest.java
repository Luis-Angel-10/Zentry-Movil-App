package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class InviteMemberRequest {

    @NotBlank
    private String username;
}
