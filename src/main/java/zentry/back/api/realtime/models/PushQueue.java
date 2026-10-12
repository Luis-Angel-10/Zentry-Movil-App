package zentry.back.api.realtime.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "push_queue", schema = "zentry_realtime")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class PushQueue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "message", nullable = false, columnDefinition = "TEXT")
    private String message;

    @Column(name = "sent")
    private Boolean sent;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
