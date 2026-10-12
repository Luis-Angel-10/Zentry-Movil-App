package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommentRequest {

    @NotBlank
    @Size(max = 1000)
    private String content;
}
