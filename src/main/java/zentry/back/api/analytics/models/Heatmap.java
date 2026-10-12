package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "heatmaps", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Heatmap {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "page", length = 255, nullable = false)
    private String page;

    @Column(name = "click_data", columnDefinition = "JSONB", nullable = false)
    private String clickData;

    @Column(name = "recorded_at")
    private LocalDateTime recordedAt;
}
