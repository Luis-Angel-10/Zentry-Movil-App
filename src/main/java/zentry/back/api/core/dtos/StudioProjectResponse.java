package zentry.back.api.core.dtos;

import zentry.back.api.core.models.ContentType;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class StudioProjectResponse {

    private Integer id;
    private String title;
    private String description;
    private ContentType type;
    private String contentData;
    private String mediaUrl;
    private List<String> tools;
    private Integer rewardCoins;
    private String ownerUsername;
    private Boolean published;
    private Integer postId;
    private LocalDateTime createdAt;
    private LocalDateTime lastEditedAt;
}
