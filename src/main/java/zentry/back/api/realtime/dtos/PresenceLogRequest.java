package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PresenceLogRequest {

    @NotNull
    private Integer userId;

    @NotBlank
    @Size(max = 10)
    private String status;
}
