package zentry.back.api.ai.dtos;

import lombok.*;


@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommunityEmbeddingsRequest {
    private Integer communityId;
    private String vector;
}
