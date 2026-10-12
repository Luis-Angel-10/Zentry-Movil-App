package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "content_performance", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class ContentPerformance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "post_id")
    private Integer postId;

    @Column(name = "views")
    private Integer views;

    @Column(name = "likes")
    private Integer likes;

    @Column(name = "recorded_at")
    private LocalDateTime recordedAt;
}
