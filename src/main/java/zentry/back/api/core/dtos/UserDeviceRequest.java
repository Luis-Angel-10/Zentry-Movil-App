package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserDeviceRequest {

    @NotNull
    private Integer userId;

    @Size(max = 100)
    private String dispositivo;
}
