package zentry.back.api.core.models;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "friendships", schema = "zentry_core")
@IdClass(Friendship.FriendshipId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Friendship {

    @Id
    @Column(name = "user1")
    private Integer user1;

    @Id
    @Column(name = "user2")
    private Integer user2;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class FriendshipId implements java.io.Serializable {
        private Integer user1;
        private Integer user2;
    }
}
