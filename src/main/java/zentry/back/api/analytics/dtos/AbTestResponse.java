package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AbTestResponse {

    private Integer id;
    private String testName;
    private String description;
    private LocalDateTime createdAt;
}
