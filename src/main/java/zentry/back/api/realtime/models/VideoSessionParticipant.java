package zentry.back.api.realtime.models;
import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;

@Entity
@Table(name = "video_session_participants", schema = "zentry_realtime")
@IdClass(VideoSessionParticipant.VideoSessionParticipantId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class VideoSessionParticipant {

    @Id
    @Column(name = "session_id")
    private Integer sessionId;

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class VideoSessionParticipantId implements Serializable {
        private Integer sessionId;
        private Integer userId;
    }
}
