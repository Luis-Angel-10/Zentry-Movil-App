package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class VoiceSessionResponse {

    private Integer id;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
}
