package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ShareResponse {

    private Integer id;
    private Integer postId;
    private Integer userId;
}
