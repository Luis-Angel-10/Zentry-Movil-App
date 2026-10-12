package zentry.back.api.ai.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaBehaivorAnalitycsResponse {
    private UUID id;
    private Integer userId;
    private BigDecimal score;
}
