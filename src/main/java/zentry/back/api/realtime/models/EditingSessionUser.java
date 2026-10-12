package zentry.back.api.realtime.models;
import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;

@Entity
@Table(name = "editing_session_users", schema = "zentry_realtime")
@IdClass(EditingSessionUser.EditingSessionUserId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class EditingSessionUser {

    @Id
    @Column(name = "session_id")
    private Integer sessionId;

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class EditingSessionUserId implements Serializable {
        private Integer sessionId;
        private Integer userId;
    }
}
