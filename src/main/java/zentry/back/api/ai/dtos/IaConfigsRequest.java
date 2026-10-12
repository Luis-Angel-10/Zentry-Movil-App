package zentry.back.api.ai.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaConfigsRequest {
    private Integer modelId;
    private String parametros;
}
