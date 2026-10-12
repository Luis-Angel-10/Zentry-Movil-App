package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class FriendshipRequest {

    @NotNull
    private Integer user1;

    @NotNull
    private Integer user2;
}
