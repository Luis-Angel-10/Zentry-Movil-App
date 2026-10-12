package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.Size;
import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class VideoSessionRequest {

    @Size(max = 20)
    private String quality;

    private LocalDateTime startedAt;
}
