package zentry.back.api.ai.dtos;

import lombok.*;
import java.sql.Timestamp;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaTrainingLogsRequest {
    private Integer modelId;
    private String estado;
    private Timestamp fecha;
}
