package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class EditingChangeResponse {

    private Integer id;
    private Integer sessionId;
    private String changeData;
    private LocalDateTime createdAt;
}
