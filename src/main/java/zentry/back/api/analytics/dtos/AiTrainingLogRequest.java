package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AiTrainingLogRequest {

    @NotBlank
    @Size(max = 100)
    private String model;

    private String inputData;

    private String outputData;
}
