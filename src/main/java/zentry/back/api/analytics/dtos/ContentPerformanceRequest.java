package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ContentPerformanceRequest {

    @NotNull
    private Integer postId;

    private Integer views;

    private Integer likes;
}
