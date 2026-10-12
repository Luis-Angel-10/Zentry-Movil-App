package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class StreamEventResponse {

    private Integer id;
    private String streamId;
    private Integer userId;
    private String action;
    private LocalDateTime createdAt;
}
