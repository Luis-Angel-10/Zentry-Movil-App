package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AbTestRequest {

    @NotBlank
    @Size(max = 100)
    private String testName;

    private String description;
}
