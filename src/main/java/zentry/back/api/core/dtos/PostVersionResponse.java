package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PostVersionResponse {

    private Integer id;
    private Integer postId;
    private String contenido;
}
