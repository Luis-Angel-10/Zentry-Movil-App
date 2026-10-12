package zentry.back.api.analytics.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ScrollTrackingResponse {

    private Integer id;
    private Integer userId;
    private String page;
    private BigDecimal depth;
    private LocalDateTime timestamp;
}
