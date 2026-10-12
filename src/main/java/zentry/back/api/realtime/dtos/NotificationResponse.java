package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class NotificationResponse {

    private Integer id;
    private Integer userId;
    private String type;
    private String data;
    private Boolean read;
    private LocalDateTime createdAt;
}
