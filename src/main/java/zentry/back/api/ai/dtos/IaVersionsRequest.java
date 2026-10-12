package zentry.back.api.ai.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaVersionsRequest {
    private Integer modelId;
    private String version;
}
