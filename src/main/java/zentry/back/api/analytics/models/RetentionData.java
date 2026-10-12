package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "retention_data", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class RetentionData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "cohort", length = 50, nullable = false)
    private String cohort;

    @Column(name = "retention_rate", precision = 5, scale = 4)
    private BigDecimal retentionRate;

    @Column(name = "recorded_at")
    private LocalDateTime recordedAt;
}
