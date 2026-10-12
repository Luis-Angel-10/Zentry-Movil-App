package zentry.back.api.core.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class TrendingTopicResponse {

    private Long id;
    private String hashtag;
    private String category;
    private Long postsCount;
    private Boolean isHot;
    private Integer year;
    private LocalDateTime updatedAt;
}
