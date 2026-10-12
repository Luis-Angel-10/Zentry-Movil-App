package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class StoreItemResponse {
    private Integer id;
    private String name;
    private String description;
    private String type;
    private String rarity;
    private Integer price;
    private String imageUrl;
    private Boolean owned;
}
