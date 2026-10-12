package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ConversationParticipantRequest {

    @NotNull
    private Integer conversationId;

    @NotNull
    private Integer userId;
}
