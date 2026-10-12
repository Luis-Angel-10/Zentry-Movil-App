package zentry.back.api.realtime.models;
import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "typing_status", schema = "zentry_realtime")
@IdClass(TypingStatus.TypingStatusId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class TypingStatus {

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @Id
    @Column(name = "conversation_id")
    private Integer conversationId;

    @Column(name = "is_typing")
    private Boolean isTyping;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class TypingStatusId implements Serializable {
        private Integer userId;
        private Integer conversationId;
    }
}
