package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "engagement_metrics", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class EngagementMetric {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "score", precision = 10, scale = 4)
    private BigDecimal score;

    @Column(name = "recorded_at")
    private LocalDateTime recordedAt;
}
