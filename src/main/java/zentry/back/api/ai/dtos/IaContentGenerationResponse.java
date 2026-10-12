package zentry.back.api.ai.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaContentGenerationResponse {
    private UUID id;
    private Integer promptId;
    private String resultado;
}
