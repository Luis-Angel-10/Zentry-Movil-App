package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class FriendRequestResponse {

    private Integer id;
    private Integer user1;
    private Integer user2;
}
