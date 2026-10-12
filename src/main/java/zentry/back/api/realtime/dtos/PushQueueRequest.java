package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PushQueueRequest {

    @NotNull
    private Integer userId;

    @NotBlank
    private String message;

    private Boolean sent;
}
