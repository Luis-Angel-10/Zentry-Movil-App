package zentry.back.api.realtime.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity(name = "RealtimeNotification")
@Table(name = "notifications", schema = "zentry_realtime")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "type", nullable = false, length = 50)
    private String type;

    @Column(name = "data", columnDefinition = "jsonb")
    private String data;

    @Column(name = "read")
    private Boolean read;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
