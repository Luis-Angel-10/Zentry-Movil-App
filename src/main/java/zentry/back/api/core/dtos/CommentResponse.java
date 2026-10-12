package zentry.back.api.core.dtos;

import lombok.*;

import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommentResponse {

    private Integer id;
    private Integer postId;
    private Integer userId;
    private String authorUsername;
    private String authorAvatarUrl;
    private String content;
    private LocalDateTime createdAt;
}
