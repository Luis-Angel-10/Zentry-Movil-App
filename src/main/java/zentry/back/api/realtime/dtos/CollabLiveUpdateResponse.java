package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CollabLiveUpdateResponse {

    private Integer id;
    private Integer projectId;
    private String updateData;
    private LocalDateTime createdAt;
}
