package zentry.back.api.core.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class StoryGroupResponse {

    @JsonProperty("user_id")
    private Integer userId;

    private String username;

    private String name;

    private String avatar;

    @JsonProperty("avatar_url")
    private String avatarUrl;

    @JsonProperty("is_user")
    private Boolean isUser;

    @JsonProperty("has_unseen")
    private Boolean hasUnseen;

    @JsonProperty("last_updated")
    private LocalDateTime lastUpdated;

    private List<StoryResponse> items;
}
