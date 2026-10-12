package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class FriendRequestRequest {

    @NotNull
    private Integer user1;

    @NotNull
    private Integer user2;
}
