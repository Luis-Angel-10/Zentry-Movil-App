package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class FeatureUsageResponse {

    private Integer id;
    private String feature;
    private Integer usageCount;
    private LocalDateTime recordedAt;
}
