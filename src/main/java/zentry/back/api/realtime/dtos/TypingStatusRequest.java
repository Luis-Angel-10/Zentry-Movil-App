package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class TypingStatusRequest {

    @NotNull
    private Integer userId;

    @NotNull
    private Integer conversationId;

    @NotNull
    private Boolean isTyping;
}
