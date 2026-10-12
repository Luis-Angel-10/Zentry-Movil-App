package zentry.back.api.core.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class StorePurchaseResponse {
    private Integer id;
    private Integer userId;
    private Integer storeItemId;
    private LocalDateTime purchaseDate;
}
