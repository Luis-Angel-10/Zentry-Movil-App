package zentry.back.api.business.dtos;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SubscriptionPlansRequest {
    private String name;
    private BigDecimal precio;
    private String description;
    private String features;
}
