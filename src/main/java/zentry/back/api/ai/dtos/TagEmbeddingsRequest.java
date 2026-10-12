package zentry.back.api.ai.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class TagEmbeddingsRequest {
    private Integer tagId;
    private String vector;
}
