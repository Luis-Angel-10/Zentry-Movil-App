package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommentReactionRequest {

    @NotNull
    private Integer commentId;

    @NotNull
    private Integer userId;
}
