package zentry.back.api.analytics.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class DataLakeEventResponse {

    private Integer id;
    private String rawData;
    private String source;
    private LocalDateTime timestamp;
}
