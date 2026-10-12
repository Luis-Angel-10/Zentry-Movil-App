package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SubscribeRequest {

    @NotBlank(message = "El ID del plan es obligatorio")
    private String planId; // "free", "pro", "vip"

    private String cycle; // "monthly", "annual"
}
