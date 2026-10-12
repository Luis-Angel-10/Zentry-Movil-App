package zentry.back.api.realtime.models;
import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "conversation_participants", schema = "zentry_realtime")
@IdClass(ConversationParticipant.ConversationParticipantId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class ConversationParticipant {

    @Id
    @Column(name = "conversation_id")
    private Integer conversationId;

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "role", length = 20)
    private String role;

    @Column(name = "joined_at")
    private LocalDateTime joinedAt;

    @Column(name = "last_read_at")
    private LocalDateTime lastReadAt;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class ConversationParticipantId implements Serializable {
        private Integer conversationId;
        private Integer userId;
    }
}
