package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class MessageResponse {

    private Integer id;
    private Integer conversationId;
    private Integer senderId;
    private String content;
    private String type;
    private Boolean read;
    private LocalDateTime createdAt;
}
