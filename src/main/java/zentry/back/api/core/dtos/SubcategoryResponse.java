package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SubcategoryResponse {

    private Integer id;
    private Integer categoriaId;
}
