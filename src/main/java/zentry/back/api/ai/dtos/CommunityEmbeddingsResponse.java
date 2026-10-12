package zentry.back.api.ai.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommunityEmbeddingsResponse {
    private UUID id;
    private Integer communityId;
    private String vector;
}
