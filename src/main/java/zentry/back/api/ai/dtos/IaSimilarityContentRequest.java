package zentry.back.api.ai.dtos;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaSimilarityContentRequest {
    private Integer postId1;
    private Integer postId2;
    private BigDecimal score;
}
