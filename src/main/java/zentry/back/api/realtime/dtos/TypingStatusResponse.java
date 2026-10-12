package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class TypingStatusResponse {

    private Integer userId;
    private Integer conversationId;
    private Boolean isTyping;
    private LocalDateTime updatedAt;
}
