package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "click_stream", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class ClickStream {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "element", length = 255)
    private String element;

    @Column(name = "page", length = 255)
    private String page;

    @Column(name = "timestamp")
    private LocalDateTime timestamp;
}
