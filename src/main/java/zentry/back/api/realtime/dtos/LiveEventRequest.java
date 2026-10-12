package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class LiveEventRequest {

    @NotBlank
    @Size(max = 50)
    private String eventType;

    private String payload;
}
