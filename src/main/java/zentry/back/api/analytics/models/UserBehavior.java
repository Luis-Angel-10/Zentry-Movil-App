package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_behavior", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class UserBehavior {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "type", length = 50, nullable = false)
    private String type;

    @Column(name = "metadata", columnDefinition = "JSONB")
    private String metadata;

    @Column(name = "timestamp")
    private LocalDateTime timestamp;
}
