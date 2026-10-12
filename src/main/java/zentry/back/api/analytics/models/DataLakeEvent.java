package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "data_lake_events", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class DataLakeEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "raw_data", columnDefinition = "JSONB", nullable = false)
    private String rawData;

    @Column(name = "source", length = 50)
    private String source;

    @Column(name = "timestamp")
    private LocalDateTime timestamp;
}
