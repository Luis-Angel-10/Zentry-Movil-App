package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "performance_logs", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class PerformanceLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "metric", length = 100, nullable = false)
    private String metric;

    @Column(name = "value", precision = 15, scale = 4)
    private BigDecimal value;

    @Column(name = "timestamp")
    private LocalDateTime timestamp;
}
