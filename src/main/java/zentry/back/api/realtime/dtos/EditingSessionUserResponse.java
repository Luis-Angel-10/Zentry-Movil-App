package zentry.back.api.realtime.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class EditingSessionUserResponse {

    private Integer sessionId;
    private Integer userId;
}
