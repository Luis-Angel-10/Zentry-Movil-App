package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PerformanceLogRequest {

    @NotBlank
    @Size(max = 100)
    private String metric;

    private BigDecimal value;
}
