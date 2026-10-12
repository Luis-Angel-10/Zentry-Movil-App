package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ErrorTrackingResponse {

    private Integer id;
    private String error;
    private String stackTrace;
    private Integer userId;
    private LocalDateTime timestamp;
}
