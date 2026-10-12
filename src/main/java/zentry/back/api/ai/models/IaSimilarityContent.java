package zentry.back.api.ai.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;
import zentry.back.api.core.models.Post;

@Entity
@Table(name = "ai_similarity_content", schema = "zentry_ai")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class IaSimilarityContent {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "post_id_1", nullable = false)
    private Integer postId1;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id_1", insertable = false, updatable = false)
    private Post post1;

    @Column(name = "post_id_2", nullable = false)
    private Integer postId2;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id_2", insertable = false, updatable = false)
    private Post post2;

    @Column(name = "score", nullable = false, precision = 5, scale = 4)
    private BigDecimal score;
}
