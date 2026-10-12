package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserBehaviorResponse {

    private Integer id;
    private Integer userId;
    private String type;
    private String metadata;
    private LocalDateTime timestamp;
}
