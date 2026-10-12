package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "post_likes", schema = "zentry_core")
@IdClass(PostLike.PostLikeId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class PostLike {

    @Id
    @Column(name = "post_id")
    private Integer postId;

    @Id
    @Column(name = "user_id")
    private Integer userId;

    private LocalDateTime createdAt;

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @EqualsAndHashCode
    public static class PostLikeId implements Serializable {
        private Integer postId;
        private Integer userId;
    }
}
