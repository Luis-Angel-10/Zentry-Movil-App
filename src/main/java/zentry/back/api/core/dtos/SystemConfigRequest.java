package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SystemConfigRequest {

    @NotBlank
    @Size(max = 100)
    private String clave;
}
