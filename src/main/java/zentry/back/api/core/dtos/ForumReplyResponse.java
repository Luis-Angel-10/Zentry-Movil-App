package zentry.back.api.core.dtos;

import lombok.*;

import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ForumReplyResponse {

    private Integer id;
    private Integer threadId;
    private Integer authorUserId;
    private String authorUsername;
    private String authorAvatarUrl;
    private String content;
    private LocalDateTime createdAt;
}
