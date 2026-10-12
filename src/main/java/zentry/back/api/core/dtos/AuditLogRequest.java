package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AuditLogRequest {

    @NotBlank
    private String accion;
}
