package zentry.back.api.business.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class InvoicesItemsRequest {
    private UUID invoiceId;
    private String descripcion;
    private BigDecimal precio;
}
