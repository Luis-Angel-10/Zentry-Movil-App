package zentry.back.api.analytics.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class EngagementMetricResponse {

    private Integer id;
    private Integer userId;
    private BigDecimal score;
    private LocalDateTime recordedAt;
}
