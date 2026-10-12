package zentry.back.api.ai.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import zentry.back.api.core.models.User;

@Entity
@Table(name = "ai_similarity_users", schema = "zentry_ai")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@IdClass(IaSimilarityUsersId.class)
public class IaSimilarityUsers {

    @Id
    @Column(name = "user1", nullable = false)
    private Integer user1;

    @Id
    @Column(name = "user2", nullable = false)
    private Integer user2;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user1", insertable = false, updatable = false)
    private User userOne;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user2", insertable = false, updatable = false)
    private User userTwo;

    @Column(name = "score", nullable = false, precision = 5, scale = 4)
    private BigDecimal score;
}
