package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "missions", schema = "zentry_core")
@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class Mission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    private String title;
    
    @Column(length = 500)
    private String description;
    
    private Integer rewardCoins;

    // e.g. "daily_login", "create_post", "reach_streak"
    private String requirementType;

    // The target number to reach (e.g. 5 posts, 3 days streak)
    private Integer requirementValue;

    // Categoría de la misión (social, creation, community, exploration, streak) — solo para agrupar en UI
    private String category;

    // Nombre de icono lucide-react (ej. "Heart", "Sparkles") — solo para UI
    private String iconName;
}
