package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommunityMemberResponse {

    private Integer communityId;
    private Integer userId;
}
