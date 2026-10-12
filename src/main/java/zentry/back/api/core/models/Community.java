package zentry.back.api.core.models;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "communities", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Community {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "slug", unique = true, length = 120)
    private String slug;

    @Column(name = "nombre", length = 100)
    private String nombre;

    @Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "banner_url")
    private String bannerUrl;

    @Column(name = "categoria", length = 50)
    private String categoria;

    @Column(name = "creator_id", nullable = false)
    private Integer creatorId;

    @Column(name = "owner_username", length = 100)
    private String ownerUsername;

    @ElementCollection
    @CollectionTable(name = "community_rules", schema = "zentry_core", joinColumns = @JoinColumn(name = "community_id"))
    @Column(name = "rule", length = 500)
    @Builder.Default
    private List<String> rules = new ArrayList<>();

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
