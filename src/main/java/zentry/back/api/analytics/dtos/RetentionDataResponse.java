package zentry.back.api.analytics.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class RetentionDataResponse {

    private Integer id;
    private String cohort;
    private BigDecimal retentionRate;
    private LocalDateTime recordedAt;
}
