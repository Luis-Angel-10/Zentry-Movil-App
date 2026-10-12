package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class OnlineUserRequest {

    @NotNull
    private Integer userId;

    @Size(max = 10)
    private String status;
}
