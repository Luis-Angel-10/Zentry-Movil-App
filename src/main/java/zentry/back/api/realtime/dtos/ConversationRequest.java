package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ConversationRequest {

    @NotNull
    private Boolean isGroup;

    @Size(max = 100)
    private String name;

    private Integer createdBy;
}
