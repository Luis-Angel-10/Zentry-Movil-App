package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class BlockResponse {

    private Integer userId;
    private Integer blockedId;
}
