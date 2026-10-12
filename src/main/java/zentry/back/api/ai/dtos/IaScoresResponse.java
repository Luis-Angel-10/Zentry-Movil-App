package zentry.back.api.ai.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaScoresResponse {
    private UUID id;
    private Integer postId;
    private BigDecimal score;
}
