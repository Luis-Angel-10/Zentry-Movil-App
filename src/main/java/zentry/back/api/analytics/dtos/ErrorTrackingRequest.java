package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ErrorTrackingRequest {

    @NotBlank
    private String error;

    private String stackTrace;

    private Integer userId;
}
