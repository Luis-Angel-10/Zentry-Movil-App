package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "stories", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Story {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "media_url", length = 1000)
    private String mediaUrl;

    @Column(name = "media_type", length = 20, nullable = false)
    @Builder.Default
    private String mediaType = "IMAGE"; // IMAGE, VIDEO, TEXT

    @Column(name = "text_content", columnDefinition = "TEXT")
    private String textContent;

    @Column(name = "text_color", length = 50)
    private String textColor;

    @Column(name = "background", length = 500)
    private String background;

    @Column(name = "font_style", length = 50)
    private String fontStyle;

    @Column(name = "caption", length = 500)
    private String caption;

    @Column(name = "music_title", length = 100)
    private String musicTitle;

    @Column(name = "music_artist", length = 100)
    private String musicArtist;

    @Column(name = "music_url", length = 1000)
    private String musicUrl;

    @Column(name = "link_url", length = 1000)
    private String linkUrl;

    @Column(name = "duration")
    @Builder.Default
    private Integer duration = 5000; // milliseconds

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    @Column(name = "view_count")
    @Builder.Default
    private Integer viewCount = 0;

    @Column(name = "likes_count")
    @Builder.Default
    private Integer likesCount = 0;

    @Column(name = "is_archived")
    @Builder.Default
    private Boolean isArchived = false;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
        if (this.expiresAt == null) {
            // Instagram stories expire after 24 hours
            this.expiresAt = this.createdAt.plusHours(24);
        }
        if (this.viewCount == null) {
            this.viewCount = 0;
        }
        if (this.likesCount == null) {
            this.likesCount = 0;
        }
        if (this.isArchived == null) {
            this.isArchived = false;
        }
        if (this.duration == null) {
            this.duration = 5000;
        }
        if (this.mediaType == null) {
            this.mediaType = "IMAGE";
        }
    }
}
