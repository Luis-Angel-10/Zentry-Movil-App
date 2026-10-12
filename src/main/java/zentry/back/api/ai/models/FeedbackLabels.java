package zentry.back.api.ai.models;
import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "feedback_labels", schema = "zentry_ai")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class FeedbackLabels {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "feedback_id", nullable = false)
    private Integer feedbackId;

    @Column(name = "etiqueta", length = 50, nullable = false)
    private String etiqueta;
}
