package zentry.back.api.ai.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaRecommendationsResponse {
    private UUID id;
    private Integer userId;
    private Integer contenidoId;
    private BigDecimal score;
}
