package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ScrollTrackingRequest {

    @NotNull
    private Integer userId;

    @Size(max = 255)
    private String page;

    private BigDecimal depth;
}
