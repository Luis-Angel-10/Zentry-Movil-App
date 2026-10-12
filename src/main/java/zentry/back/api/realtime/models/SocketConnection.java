package zentry.back.api.realtime.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "socket_connections", schema = "zentry_realtime")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class SocketConnection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "socket_id", nullable = false, unique = true, length = 100)
    private String socketId;

    @Column(name = "connected_at")
    private LocalDateTime connectedAt;
}
