package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ReactionRequest {

    @NotNull
    private Integer postId;

    @NotNull
    private Integer userId;
}
