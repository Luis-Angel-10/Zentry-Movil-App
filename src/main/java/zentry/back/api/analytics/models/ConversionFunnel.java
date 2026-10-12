package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "conversion_funnels", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class ConversionFunnel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "funnel_name", length = 100, nullable = false)
    private String funnelName;

    @Column(name = "steps", columnDefinition = "JSONB", nullable = false)
    private String steps;

    @Column(name = "conversions")
    private Integer conversions;

    @Column(name = "recorded_at")
    private LocalDateTime recordedAt;
}
