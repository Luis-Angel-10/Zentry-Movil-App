package zentry.back.api.ai.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaSimilarityContentResponse {
    private UUID id;
    private Integer postId1;
    private Integer postId2;
    private BigDecimal score;
}
