package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "store_purchases", schema = "zentry_core")
@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class StorePurchase {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private Integer userId;
    
    private Integer storeItemId;
    
    private LocalDateTime purchaseDate;
}
