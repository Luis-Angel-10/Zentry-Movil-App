package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ConversionFunnelRequest {

    @NotBlank
    @Size(max = 100)
    private String funnelName;

    @NotBlank
    private String steps;

    private Integer conversions;
}
