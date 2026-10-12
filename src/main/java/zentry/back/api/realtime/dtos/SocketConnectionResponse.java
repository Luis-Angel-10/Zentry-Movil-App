package zentry.back.api.realtime.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SocketConnectionResponse {

    private Integer id;
    private Integer userId;
    private String socketId;
    private LocalDateTime connectedAt;
}
