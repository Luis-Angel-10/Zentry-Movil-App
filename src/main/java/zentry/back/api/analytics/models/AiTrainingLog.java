package zentry.back.api.analytics.models;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "ai_training_logs", schema = "zentry_analytics")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class AiTrainingLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "model", length = 100, nullable = false)
    private String model;

    @Column(name = "input_data", columnDefinition = "JSONB")
    private String inputData;

    @Column(name = "output_data", columnDefinition = "JSONB")
    private String outputData;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
