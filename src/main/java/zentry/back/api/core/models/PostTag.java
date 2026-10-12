package zentry.back.api.core.models;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "post_tags", schema = "zentry_core")
@IdClass(PostTag.PostTagId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class PostTag {

    @Id
    @Column(name = "post_id")
    private Integer postId;

    @Id
    @Column(name = "tag_id")
    private Integer tagId;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class PostTagId implements java.io.Serializable {
        private Integer postId;
        private Integer tagId;
    }
}
