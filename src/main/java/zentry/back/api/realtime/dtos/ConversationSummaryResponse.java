package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ConversationSummaryResponse {
    private Integer id;
    private Boolean isGroup;
    private String name;
    private Integer otherUserId;
    private String lastMessageContent;
    private Integer lastMessageSenderId;
    private LocalDateTime lastMessageAt;
    private Long unreadCount;
}
