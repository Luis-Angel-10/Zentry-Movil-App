package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class EditingSessionResponse {

    private Integer id;
    private String docId;
    private LocalDateTime createdAt;
}
