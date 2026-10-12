package zentry.back.api.ai.dtos;

import lombok.*;
import java.sql.Timestamp;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class RecommendationLogsRequest {
    private Integer recommendationId;
    private Timestamp timestamp;
}
