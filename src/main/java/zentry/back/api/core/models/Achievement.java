package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "achievements", schema = "zentry_core")
@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class Achievement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    private String title;
    
    @Column(length = 500)
    private String description;
    
    private Integer rewardCoins;
    
    private String iconUrl;

    private String requirementType; // e.g. "reach_100_followers"

    private Integer requirementValue;

    // Rareza visual: COMMON, RARE, EPIC, LEGENDARY, MYSTERIOUS
    private String rarity;

    // Categoría (creation, social, community, reputation, mastery, mystery) — solo para agrupar en UI
    private String category;

    @Builder.Default
    private Boolean isSecret = false;

    @Column(length = 300)
    private String secretHint;
}
