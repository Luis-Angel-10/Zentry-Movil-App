package zentry.back.api.core.dtos;

import lombok.*;

import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ForumThreadResponse {

    private Integer id;
    private Integer communityId;
    private Integer authorUserId;
    private String authorUsername;
    private String authorAvatarUrl;
    private String title;
    private String content;
    private Integer repliesCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
