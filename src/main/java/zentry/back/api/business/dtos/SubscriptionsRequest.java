package zentry.back.api.business.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SubscriptionsRequest {
    private Integer userId;
    private UUID planId;
}
