package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ConversationResponse {

    private Integer id;
    private Boolean isGroup;
    private String name;
    private Integer createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime lastMessageAt;
}
