package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SearchClickRequest {

    @NotNull
    private Integer searchLogId;

    @Size(max = 255)
    private String resultClicked;
}
