package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_achievements", schema = "zentry_core")
@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserAchievement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    private Integer userId;
    
    private Integer achievementId;

    @Builder.Default
    private Integer progress = 0;

    private LocalDateTime unlockedAt;
}
