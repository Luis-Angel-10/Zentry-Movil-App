package zentry.back.api.business.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AffiliatePayoutsResponse {
    private UUID id;
    private UUID affiliateId;
    private BigDecimal amount;
}
