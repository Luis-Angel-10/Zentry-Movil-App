package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ReactionResponse {

    private Integer id;
    private Integer postId;
    private Integer userId;
}
