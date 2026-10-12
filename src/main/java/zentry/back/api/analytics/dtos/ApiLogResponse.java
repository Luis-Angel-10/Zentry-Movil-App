package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ApiLogResponse {

    private Integer id;
    private String endpoint;
    private String method;
    private Integer responseTime;
    private Integer statusCode;
    private Integer userId;
    private LocalDateTime timestamp;
}
