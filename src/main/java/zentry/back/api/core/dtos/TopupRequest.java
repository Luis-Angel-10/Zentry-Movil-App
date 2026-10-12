package zentry.back.api.core.dtos;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class TopupRequest {

    @NotNull(message = "El monto es obligatorio")
    @DecimalMin(value = "1.0", message = "El monto mínimo de recarga es 1 ZC")
    private BigDecimal amount;
}
