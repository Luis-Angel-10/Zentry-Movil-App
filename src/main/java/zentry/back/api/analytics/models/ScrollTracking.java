package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "scroll_tracking", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class ScrollTracking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "page", length = 255)
    private String page;

    @Column(name = "depth", precision = 5, scale = 2)
    private BigDecimal depth;

    @Column(name = "timestamp")
    private LocalDateTime timestamp;
}
