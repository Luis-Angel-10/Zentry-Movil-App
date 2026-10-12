package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AiTrainingLogResponse {

    private Integer id;
    private String model;
    private String inputData;
    private String outputData;
    private LocalDateTime createdAt;
}
