package zentry.back.api.core.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SendFriendRequestDTO {
    @JsonProperty("target_user_id")
    private Integer targetUserId;

    @JsonProperty("target_username")
    private String targetUsername;

    private String message;
}
