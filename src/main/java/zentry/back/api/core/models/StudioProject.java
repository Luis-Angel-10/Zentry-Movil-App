package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "studio_projects", schema = "zentry_core")
@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class StudioProject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(length = 1000)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private ContentType type;

    @Column(name = "content_data", columnDefinition = "TEXT")
    private String contentData;

    @Column(name = "media_url", length = 500)
    private String mediaUrl;

    @ElementCollection
    @CollectionTable(name = "studio_project_tools", schema = "zentry_core", joinColumns = @JoinColumn(name = "project_id"))
    @Column(name = "tool", length = 100)
    @Builder.Default
    private List<String> tools = new ArrayList<>();

    @Column(name = "reward_coins")
    private Integer rewardCoins;

    @Column(name = "owner_username", nullable = false, length = 100)
    private String ownerUsername;

    @Column(name = "published", columnDefinition = "boolean default false")
    @Builder.Default
    private Boolean published = false;

    @Column(name = "post_id")
    private Integer postId;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "last_edited_at")
    private LocalDateTime lastEditedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.lastEditedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.lastEditedAt = LocalDateTime.now();
    }
}
