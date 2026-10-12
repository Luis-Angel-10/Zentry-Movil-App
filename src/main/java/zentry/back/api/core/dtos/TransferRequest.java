package zentry.back.api.core.dtos;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class TransferRequest {

    @NotBlank(message = "El usuario destinatario es obligatorio")
    private String recipientUsername;

    @NotNull(message = "El monto a transferir es obligatorio")
    @DecimalMin(value = "1.0", message = "El monto mínimo a transferir es 1 ZC")
    private BigDecimal amount;
}
