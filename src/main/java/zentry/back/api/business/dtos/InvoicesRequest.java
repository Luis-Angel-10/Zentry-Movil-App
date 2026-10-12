package zentry.back.api.business.dtos;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class InvoicesRequest {
    private Integer userId;
    private BigDecimal total;
}
