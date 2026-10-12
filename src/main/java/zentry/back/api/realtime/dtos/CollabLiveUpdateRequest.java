package zentry.back.api.realtime.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CollabLiveUpdateRequest {

    @NotNull
    private Integer projectId;

    @NotBlank
    private String updateData;
}
