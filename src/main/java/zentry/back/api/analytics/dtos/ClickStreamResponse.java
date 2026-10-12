package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ClickStreamResponse {

    private Integer id;
    private Integer userId;
    private String element;
    private String page;
    private LocalDateTime timestamp;
}
