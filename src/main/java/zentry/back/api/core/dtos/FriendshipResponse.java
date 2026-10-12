package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class FriendshipResponse {

    private Integer user1;
    private Integer user2;
}
