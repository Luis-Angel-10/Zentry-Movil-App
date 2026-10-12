package zentry.back.api.core.models;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "follows", schema = "zentry_core")
@IdClass(Follow.FollowId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Follow {

    @Id
    @Column(name = "follower")
    private Integer follower;

    @Id
    @Column(name = "following")
    private Integer following;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class FollowId implements java.io.Serializable {
        private Integer follower;
        private Integer following;
    }
}
