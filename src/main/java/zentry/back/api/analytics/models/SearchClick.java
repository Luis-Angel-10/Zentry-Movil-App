package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "search_clicks", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class SearchClick {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "search_log_id")
    private Integer searchLogId;

    @Column(name = "result_clicked", length = 255)
    private String resultClicked;

    @Column(name = "timestamp")
    private LocalDateTime timestamp;
}
