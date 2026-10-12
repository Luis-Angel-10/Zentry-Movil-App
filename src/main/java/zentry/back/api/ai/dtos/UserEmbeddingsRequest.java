package zentry.back.api.ai.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserEmbeddingsRequest {
    private Integer userId;
    private String vector;
}
