package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "ab_test_results", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class AbTestResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "test_id")
    private Integer testId;

    @Column(name = "variant", length = 50, nullable = false)
    private String variant;

    @Column(name = "result", precision = 10, scale = 4)
    private BigDecimal result;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "recorded_at")
    private LocalDateTime recordedAt;
}
