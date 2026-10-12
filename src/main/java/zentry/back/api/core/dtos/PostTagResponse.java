package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PostTagResponse {

    private Integer postId;
    private Integer tagId;
}
