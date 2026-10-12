package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity(name = "CoreNotification")
@Table(name = "notifications", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "type", nullable = false, length = 30)
    private String type;

    @Column(name = "content", length = 500)
    private String content;

    @Column(name = "source_username", length = 100)
    private String sourceUsername;

    @Column(name = "source_avatar_url", length = 500)
    private String sourceAvatarUrl;

    @Column(name = "related_id")
    private Integer relatedId;

    @Column(name = "is_read", columnDefinition = "boolean default false")
    @Builder.Default
    private Boolean read = false;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (read == null) read = false;
    }
}
