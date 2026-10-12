package zentry.back.api.realtime.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class VideoSessionParticipantResponse {

    private Integer sessionId;
    private Integer userId;
}
