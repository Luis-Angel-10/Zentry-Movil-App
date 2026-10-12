package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class EventStreamResponse {

    private Integer id;
    private String type;
    private String data;
    private LocalDateTime timestamp;
}
