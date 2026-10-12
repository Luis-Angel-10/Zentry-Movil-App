package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class LiveEventResponse {

    private Integer id;
    private String eventType;
    private String payload;
    private LocalDateTime createdAt;
}
