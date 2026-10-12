package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ProjectLikeResponse {
    private boolean liked;
    private long likesCount;
}
