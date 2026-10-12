package zentry.back.api.business.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AffiliateProgramResponse {
    private UUID id;
    private Integer userId;
}
