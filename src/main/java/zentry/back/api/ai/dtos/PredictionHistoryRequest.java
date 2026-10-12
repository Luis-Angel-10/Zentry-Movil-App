package zentry.back.api.ai.dtos;

import lombok.*;
import java.sql.Timestamp;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PredictionHistoryRequest {
    private Integer predictionId;
    private Timestamp fecha;
}
