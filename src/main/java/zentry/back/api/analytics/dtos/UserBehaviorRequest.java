package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserBehaviorRequest {

    @NotNull
    private Integer userId;

    @NotBlank
    @Size(max = 50)
    private String type;

    private String metadata;
}
