package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class RealtimeReactionResponse {

    private Integer id;
    private Integer postId;
    private Integer userId;
    private String reaction;
    private LocalDateTime createdAt;
}
