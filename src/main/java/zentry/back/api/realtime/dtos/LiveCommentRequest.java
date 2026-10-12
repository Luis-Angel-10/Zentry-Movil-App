package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class LiveCommentRequest {

    @NotNull
    private Integer postId;

    @NotNull
    private Integer userId;

    @NotBlank
    private String comment;
}
