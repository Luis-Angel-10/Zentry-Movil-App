package zentry.back.api.realtime.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class VoiceSessionParticipantResponse {

    private Integer sessionId;
    private Integer userId;
}
