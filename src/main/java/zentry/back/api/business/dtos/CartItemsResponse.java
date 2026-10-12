package zentry.back.api.business.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CartItemsResponse {
    private UUID cartId;
    private UUID productId;
    private Integer cantidad;
}
