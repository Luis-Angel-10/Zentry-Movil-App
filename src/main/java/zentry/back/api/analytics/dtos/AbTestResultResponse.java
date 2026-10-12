package zentry.back.api.analytics.dtos;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AbTestResultResponse {

    private Integer id;
    private Integer testId;
    private String variant;
    private BigDecimal result;
    private Integer userId;
    private LocalDateTime recordedAt;
}
