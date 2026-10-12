package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SearchLogResponse {

    private Integer id;
    private Integer userId;
    private String query;
    private LocalDateTime timestamp;
}
