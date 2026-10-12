package zentry.back.api.core.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class WalletResponse {

    private Long id;
    private String username;
    private BigDecimal balance;
    private String activePlanId;
    private LocalDateTime nextBillingDate;
    private List<WalletTransactionResponse> transactions;
}
