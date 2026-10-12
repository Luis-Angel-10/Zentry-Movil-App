package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SessionTrackingResponse {

    private Integer id;
    private Integer userId;
    private LocalDateTime sessionStart;
    private LocalDateTime sessionEnd;
    private Integer durationSec;
}
