package zentry.back.api.ai.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaTrainingDataRequest {
    private String dataInput;
    private String dataOutput;
}
