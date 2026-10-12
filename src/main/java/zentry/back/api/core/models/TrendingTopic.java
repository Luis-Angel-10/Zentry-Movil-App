package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "trending_topics", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class TrendingTopic {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String hashtag; // ej: "#Cyberpunk2099"

    private String category; // ej: "Arte 3D & VFX"

    private Long postsCount; // Cantidad de publicaciones relacionadas

    private Boolean isHot; // Flag de alta actividad en las últimas 24h

    private Integer year; // Para el archivo histórico (ej: 2026, 2025)

    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    public void onSave() {
        if (updatedAt == null) {
            updatedAt = LocalDateTime.now();
        }
    }
}
