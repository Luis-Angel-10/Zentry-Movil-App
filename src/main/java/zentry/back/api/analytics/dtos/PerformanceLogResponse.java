package zentry.back.api.analytics.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PerformanceLogResponse {

    private Integer id;
    private String metric;
    private BigDecimal value;
    private LocalDateTime timestamp;
}
