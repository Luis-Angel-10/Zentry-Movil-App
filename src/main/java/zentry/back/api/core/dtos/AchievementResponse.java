package zentry.back.api.core.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AchievementResponse {
    private Integer id;
    private String title;
    private String description;
    private Integer rewardCoins;
    private String iconUrl;
    private String requirementType;
    private Integer requirementValue;
    private String rarity;
    private String category;
    private Boolean isSecret;
    private String secretHint;
    private Integer progress;
    private Boolean unlocked;
    private LocalDateTime unlockedAt;
}
