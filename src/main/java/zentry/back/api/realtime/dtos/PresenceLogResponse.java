package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PresenceLogResponse {

    private Integer id;
    private Integer userId;
    private String status;
    private LocalDateTime timestamp;
}
