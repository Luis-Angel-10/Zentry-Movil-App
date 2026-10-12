package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ConversationParticipantResponse {

    private Integer conversationId;
    private Integer userId;
    private String role;
    private LocalDateTime joinedAt;
    private LocalDateTime lastReadAt;
}
