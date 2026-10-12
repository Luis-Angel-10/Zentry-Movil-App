package zentry.back.api.ai.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class TagEmbeddingsResponse {
    private UUID id;
    private Integer tagId;
    private String vector;
}
