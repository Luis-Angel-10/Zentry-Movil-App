package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommentReactionResponse {

    private Integer id;
    private Integer commentId;
    private Integer userId;
}
