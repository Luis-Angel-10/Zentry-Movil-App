package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class RecommendationLogRequest {

    @NotNull
    private Integer userId;

    private String recommendations;
}
