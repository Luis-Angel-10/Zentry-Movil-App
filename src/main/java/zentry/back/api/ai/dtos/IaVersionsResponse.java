package zentry.back.api.ai.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaVersionsResponse {
    private UUID id;
    private Integer modelId;
    private String version;
}
