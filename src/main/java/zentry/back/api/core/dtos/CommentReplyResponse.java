package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommentReplyResponse {

    private Integer id;
    private Integer commentId;
}
