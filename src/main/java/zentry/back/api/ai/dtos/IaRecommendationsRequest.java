package zentry.back.api.ai.dtos;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaRecommendationsRequest {
    private Integer userId;
    private Integer contenidoId;
    private BigDecimal score;
}
