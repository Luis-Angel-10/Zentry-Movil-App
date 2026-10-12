package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class MessageRequest {

    @NotNull
    private Integer conversationId;

    private String content;

    @Size(max = 10)
    private String type;
}
