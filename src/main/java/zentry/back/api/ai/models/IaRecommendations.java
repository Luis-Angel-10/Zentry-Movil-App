package zentry.back.api.ai.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;
import zentry.back.api.core.models.User;
import zentry.back.api.core.models.Post;

@Entity
@Table(name = "ai_recommendations", schema = "zentry_ai")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class IaRecommendations {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @Column(name = "contenido_id", nullable = false)
    private Integer contenidoId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "contenido_id", insertable = false, updatable = false)
    private Post contenido;

    @Column(name = "score", nullable = false, precision = 5, scale = 4)
    private BigDecimal score;
}
