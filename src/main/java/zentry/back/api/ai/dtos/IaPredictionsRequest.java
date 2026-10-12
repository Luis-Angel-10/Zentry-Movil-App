package zentry.back.api.ai.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaPredictionsRequest {
    private Integer modelId;
    private String resultado;
}
