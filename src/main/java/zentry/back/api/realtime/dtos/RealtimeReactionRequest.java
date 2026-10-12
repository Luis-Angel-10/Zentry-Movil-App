package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class RealtimeReactionRequest {

    @NotNull
    private Integer postId;

    @NotNull
    private Integer userId;

    @NotBlank
    @Size(max = 20)
    private String reaction;
}
