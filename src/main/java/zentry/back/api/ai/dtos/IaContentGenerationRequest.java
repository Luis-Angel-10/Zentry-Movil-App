package zentry.back.api.ai.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaContentGenerationRequest {
    private Integer promptId;
    private String resultado;
}
