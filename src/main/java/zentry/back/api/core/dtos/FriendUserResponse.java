package zentry.back.api.core.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class FriendUserResponse {
    private Integer id;
    private String username;
    private String name;

    @JsonProperty("avatar_url")
    private String avatarUrl;

    private String discipline;
    private String bio;

    @JsonProperty("is_online")
    private boolean isOnline;

    private String status;

    @JsonProperty("last_seen")
    private LocalDateTime lastSeen;

    @JsonProperty("request_id")
    private Integer requestId;

    @JsonProperty("mutual_friends_count")
    private Integer mutualFriendsCount;

    @JsonProperty("project_title")
    private String projectTitle;
}
