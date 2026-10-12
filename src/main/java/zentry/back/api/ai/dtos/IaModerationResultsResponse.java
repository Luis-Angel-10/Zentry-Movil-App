package zentry.back.api.ai.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaModerationResultsResponse {
    private UUID id;
    private Integer postId;
    private String resultado;
}
