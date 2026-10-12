package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SearchClickResponse {

    private Integer id;
    private Integer searchLogId;
    private String resultClicked;
    private LocalDateTime timestamp;
}
