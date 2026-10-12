package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ApiLogRequest {

    @NotBlank
    @Size(max = 255)
    private String endpoint;

    @Size(max = 10)
    private String method;

    private Integer responseTime;

    private Integer statusCode;

    private Integer userId;
}
