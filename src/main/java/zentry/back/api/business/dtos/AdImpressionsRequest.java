package zentry.back.api.business.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AdImpressionsRequest {
    private UUID campaignId;
    private Integer vistas;
}
