package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class VideoSessionResponse {

    private Integer id;
    private String quality;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
}
