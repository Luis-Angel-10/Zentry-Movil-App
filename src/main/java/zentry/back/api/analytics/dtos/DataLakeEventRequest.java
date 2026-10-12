package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class DataLakeEventRequest {

    @NotBlank
    private String rawData;

    @Size(max = 50)
    private String source;
}
