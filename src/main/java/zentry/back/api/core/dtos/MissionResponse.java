package zentry.back.api.core.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class MissionResponse {
    private Integer id;
    private String title;
    private String description;
    private Integer rewardCoins;
    private String requirementType;
    private Integer requirementValue;
    private String category;
    private String iconName;
    private Integer progress;
    private Boolean completed;
    private LocalDateTime completedAt;
}
