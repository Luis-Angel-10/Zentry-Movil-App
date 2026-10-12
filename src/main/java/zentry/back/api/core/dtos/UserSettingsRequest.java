package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserSettingsRequest {

    @NotNull
    private Integer userId;

    @Size(max = 20)
    private String privacidad;
}
