package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class HeatmapRequest {

    @NotBlank
    @Size(max = 255)
    private String page;

    @NotBlank
    private String clickData;
}
