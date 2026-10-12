package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_missions", schema = "zentry_core")
@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserMission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private Integer userId;

    private Integer missionId;

    private Integer progress; // e.g. 3 out of 5

    private Boolean isCompleted;

    private LocalDateTime completedAt;

    // Día (UTC) al que corresponde el progreso actual — permite que las misiones
    // se reinicien automáticamente cada día en vez de completarse una sola vez para siempre.
    @Column(name = "reset_date")
    private LocalDate resetDate;
}
