package zentry.back.api.realtime.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "online_users", schema = "zentry_realtime")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class OnlineUser {

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "status", length = 10)
    private String status;

    @Column(name = "last_seen")
    private LocalDateTime lastSeen;
}
