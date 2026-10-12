package zentry.back.api.ai.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaConfigsResponse {
    private UUID id;
    private Integer modelId;
    private String parametros;
}
