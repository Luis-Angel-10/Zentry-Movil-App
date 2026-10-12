package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PostMediaResponse {

    private Integer id;
    private Integer postId;
    private String url;
}
