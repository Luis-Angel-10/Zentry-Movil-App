package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ClickStreamRequest {

    @NotNull
    private Integer userId;

    @Size(max = 255)
    private String element;

    @Size(max = 255)
    private String page;
}
