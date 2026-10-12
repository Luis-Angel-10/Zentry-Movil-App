package zentry.back.api.business.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PaymentsRequest {
    private Integer userId;
    private UUID paymentMethodId;
    private BigDecimal amount;
}
