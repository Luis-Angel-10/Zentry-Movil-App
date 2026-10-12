package zentry.back.api.business.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class MarketplaceProductsResponse {
    private UUID id;
    private Integer sellerId;
    private String nombre;
    private BigDecimal precio;
}
