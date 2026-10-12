package zentry.back.api.ai.models;
import jakarta.persistence.*;
import lombok.*;
import zentry.back.api.core.models.User;

@Entity
@Table(name = "user_embeddings", schema = "zentry_ai")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class UserEmbeddings {

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @Column(name = "vector", nullable = false, columnDefinition = "TEXT")
    private String vector;
}
