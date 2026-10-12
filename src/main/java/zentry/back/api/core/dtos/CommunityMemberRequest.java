package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommunityMemberRequest {

    @NotNull
    private Integer communityId;

    @NotNull
    private Integer userId;
}
