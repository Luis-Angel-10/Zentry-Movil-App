package zentry.back.api.ai.dtos;

import lombok.*;
import java.sql.Timestamp;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class RecommendationLogsResponse {
    private UUID id;
    private Integer recommendationId;
    private Timestamp timestamp;
}
