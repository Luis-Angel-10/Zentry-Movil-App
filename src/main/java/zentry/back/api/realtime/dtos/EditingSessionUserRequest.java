package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class EditingSessionUserRequest {

    @NotNull
    private Integer sessionId;

    @NotNull
    private Integer userId;
}
