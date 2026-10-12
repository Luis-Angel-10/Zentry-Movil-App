package zentry.back.api.business.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class MarketplaceOrdersResponse {
    private UUID id;
    private Integer buyerId;
    private BigDecimal total;
}
