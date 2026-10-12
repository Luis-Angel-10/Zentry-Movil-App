package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_equipped_items", schema = "zentry_core")
@IdClass(UserEquippedItem.UserEquippedItemId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class UserEquippedItem {

    @Id
    @Column(name = "user_id")
    private Integer userId;

    // Categoría del ítem equipado (frames/pets/banners/themes/titles) — un solo
    // ítem equipado por categoría a la vez.
    @Id
    @Column(name = "category")
    private String category;

    @Column(name = "store_item_id", nullable = false)
    private Integer storeItemId;

    @Column(name = "equipped_at")
    private LocalDateTime equippedAt;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class UserEquippedItemId implements Serializable {
        private Integer userId;
        private String category;
    }
}
