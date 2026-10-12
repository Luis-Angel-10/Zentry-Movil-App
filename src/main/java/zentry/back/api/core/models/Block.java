package zentry.back.api.core.models;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "blocks", schema = "zentry_core")
@IdClass(Block.BlockId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Block {

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @Id
    @Column(name = "blocked_id")
    private Integer blockedId;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class BlockId implements java.io.Serializable {
        private Integer userId;
        private Integer blockedId;
    }
}
