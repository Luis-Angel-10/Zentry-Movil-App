package zentry.back.api.ai.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaModerationResultsRequest {
    private Integer postId;
    private String resultado;
}
