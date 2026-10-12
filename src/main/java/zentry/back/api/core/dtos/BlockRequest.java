package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class BlockRequest {

    @NotNull
    private Integer userId;

    @NotNull
    private Integer blockedId;
}
