package zentry.back.api.core.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class StoryResponse {

    private Integer id;

    @JsonProperty("user_id")
    private Integer userId;

    private String username;

    @JsonProperty("user_name")
    private String name;

    @JsonProperty("user_avatar")
    private String avatarUrl;

    @JsonProperty("media_url")
    private String mediaUrl;

    @JsonProperty("media_type")
    private String mediaType;

    @JsonProperty("text_content")
    private String textContent;

    @JsonProperty("text_color")
    private String textColor;

    private String background;

    @JsonProperty("font_style")
    private String fontStyle;

    private String caption;

    @JsonProperty("music_title")
    private String musicTitle;

    @JsonProperty("music_artist")
    private String musicArtist;

    @JsonProperty("music_url")
    private String musicUrl;

    @JsonProperty("link_url")
    private String linkUrl;

    private Integer duration;

    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    @JsonProperty("expires_at")
    private LocalDateTime expiresAt;

    @JsonProperty("view_count")
    private Integer viewCount;

    @JsonProperty("likes_count")
    private Integer likesCount;

    @JsonProperty("is_viewed")
    private Boolean isViewed;

    @JsonProperty("is_liked")
    private Boolean isLiked;

    @JsonProperty("is_archived")
    private Boolean isArchived;
}
