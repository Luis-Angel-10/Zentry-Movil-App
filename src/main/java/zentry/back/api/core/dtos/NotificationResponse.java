package zentry.back.api.core.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class NotificationResponse {

    private Integer id;
    private String type;
    private String content;
    private String sourceUsername;
    private String sourceAvatarUrl;
    private Integer relatedId;
    private Boolean read;

    @JsonProperty("created_at")
    private LocalDateTime createdAt;
}
