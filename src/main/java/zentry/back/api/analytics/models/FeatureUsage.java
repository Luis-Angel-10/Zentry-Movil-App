package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "feature_usage", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class FeatureUsage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "feature", length = 100, nullable = false)
    private String feature;

    @Column(name = "usage_count")
    private Integer usageCount;

    @Column(name = "recorded_at")
    private LocalDateTime recordedAt;
}
