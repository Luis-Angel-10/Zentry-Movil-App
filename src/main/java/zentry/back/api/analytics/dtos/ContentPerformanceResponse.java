package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ContentPerformanceResponse {

    private Integer id;
    private Integer postId;
    private Integer views;
    private Integer likes;
    private LocalDateTime recordedAt;
}
