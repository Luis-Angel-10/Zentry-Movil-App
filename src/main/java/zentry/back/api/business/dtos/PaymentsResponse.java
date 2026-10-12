package zentry.back.api.business.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PaymentsResponse {
    private UUID id;
    private Integer userId;
    private UUID paymentMethodId;
    private BigDecimal amount;
}
