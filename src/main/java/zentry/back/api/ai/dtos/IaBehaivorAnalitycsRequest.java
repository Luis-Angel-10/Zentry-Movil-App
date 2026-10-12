package zentry.back.api.ai.dtos;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaBehaivorAnalitycsRequest {
    private Integer userId;
    private BigDecimal score;
}
