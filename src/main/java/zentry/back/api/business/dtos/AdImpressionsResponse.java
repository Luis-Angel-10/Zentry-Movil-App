package zentry.back.api.business.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AdImpressionsResponse {
    private UUID id;
    private UUID campaignId;
    private Integer vistas;
}
