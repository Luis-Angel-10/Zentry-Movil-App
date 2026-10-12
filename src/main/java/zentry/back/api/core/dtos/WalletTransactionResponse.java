package zentry.back.api.core.dtos;

import lombok.*;
import zentry.back.api.core.models.TransactionType;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class WalletTransactionResponse {

    private Long id;
    private String username;
    private TransactionType type;
    private BigDecimal amount;
    private String description;
    private LocalDateTime createdAt;
}
