package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SessionTrackingRequest {

    @NotNull
    private Integer userId;

    @NotNull
    private LocalDateTime sessionStart;

    private LocalDateTime sessionEnd;
}
