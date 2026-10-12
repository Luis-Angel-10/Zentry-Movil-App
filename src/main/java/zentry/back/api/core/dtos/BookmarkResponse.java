package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class BookmarkResponse {

    private Integer id;
    private Integer userId;
    private Integer postId;
}
