package zentry.back.api.ai.dtos;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaSimilarityUsersResponse {
    private Integer user1;
    private Integer user2;
    private BigDecimal score;
}
