package zentry.back.api.business.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SubscriptionPlansResponse {
    private UUID id;
    private String name;
    private BigDecimal precio;
    private String description;
    private String features;
}
