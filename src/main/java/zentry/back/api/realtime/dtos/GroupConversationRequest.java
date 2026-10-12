package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.util.List;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class GroupConversationRequest {

    @NotBlank
    @Size(max = 100)
    private String name;

    @NotEmpty
    private List<Integer> participantUserIds;
}
