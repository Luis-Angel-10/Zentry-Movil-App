package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class RetentionDataRequest {

    @NotBlank
    @Size(max = 50)
    private String cohort;

    private BigDecimal retentionRate;
}
