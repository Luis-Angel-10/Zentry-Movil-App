package zentry.back.api.business.dtos;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class MarketplaceOrdersRequest {
    private Integer buyerId;
    private BigDecimal total;
}
