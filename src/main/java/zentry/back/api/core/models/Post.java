package zentry.back.api.core.models;
import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;;

@Entity
@Table(name = "posts", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Post {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "contenido", columnDefinition = "TEXT")
    private String contenido;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "content_type")
    private String contentType;

    @Column(name = "thumbnail_url", columnDefinition = "TEXT")
    private String thumbnailUrl;

    @Column(name = "visibility")
    private String visibility;

    // Si no es null, la publicación se creó dentro de esta comunidad
    @Column(name = "community_id")
    private Integer communityId;

    @ElementCollection
    @CollectionTable(name = "post_tools", schema = "zentry_core", joinColumns = @JoinColumn(name = "post_id"))
    @Column(name = "tool")
    private List<String> tools;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.contentType == null) {
            this.contentType = "canvas";
        }
        if (this.visibility == null) {
            this.visibility = "public";
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    

}
