package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class HeatmapResponse {

    private Integer id;
    private String page;
    private String clickData;
    private LocalDateTime recordedAt;
}
