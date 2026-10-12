package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class MediaRequest {

    @NotNull
    private Integer postId;

    @Size(max = 255)
    private String url;
}
