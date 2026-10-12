package zentry.back.api.ai.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaTrainingDataResponse {
    private UUID id;
    private String dataInput;
    private String dataOutput;
}
