package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PushQueueResponse {

    private Integer id;
    private Integer userId;
    private String message;
    private Boolean sent;
    private LocalDateTime createdAt;
}
