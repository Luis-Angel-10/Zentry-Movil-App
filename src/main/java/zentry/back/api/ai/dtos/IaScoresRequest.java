package zentry.back.api.ai.dtos;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaScoresRequest {
    private Integer postId;
    private BigDecimal score;
}
