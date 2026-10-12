package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class StreamEventRequest {

    @NotBlank
    @Size(max = 100)
    private String streamId;

    @NotNull
    private Integer userId;

    @NotBlank
    @Size(max = 50)
    private String action;
}
