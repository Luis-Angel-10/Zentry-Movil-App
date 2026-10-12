package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class EngagementMetricRequest {

    @NotNull
    private Integer userId;

    private BigDecimal score;
}
