package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "store_items", schema = "zentry_core")
@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class StoreItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String name;
    
    @Column(length = 500)
    private String description;
    
    private String type; // e.g. "avatar_frame", "pet", "profile_background", "theme"
    
    private String rarity; // e.g. "COMMON", "RARE", "EPIC", "LEGENDARY"
    
    private Integer price; // Price in Zentry Coins (ZC)
    
    private String imageUrl; // the visual representation path
}
