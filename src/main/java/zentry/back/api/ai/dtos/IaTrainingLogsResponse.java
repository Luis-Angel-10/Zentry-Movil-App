package zentry.back.api.ai.dtos;

import lombok.*;
import java.sql.Timestamp;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaTrainingLogsResponse {
    private UUID id;
    private Integer modelId;
    private String estado;
    private Timestamp fecha;
}
