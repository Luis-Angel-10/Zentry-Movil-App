package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ConversionFunnelResponse {

    private Integer id;
    private String funnelName;
    private String steps;
    private Integer conversions;
    private LocalDateTime recordedAt;
}
