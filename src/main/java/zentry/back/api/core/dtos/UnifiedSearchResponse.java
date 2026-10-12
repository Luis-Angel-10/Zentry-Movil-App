package zentry.back.api.core.dtos;

import lombok.*;
import java.util.List;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UnifiedSearchResponse {

    private List<ProfileResponse> users;
    private List<PostResponse> arts;
    private List<TrendingTopicResponse> trending;
}
