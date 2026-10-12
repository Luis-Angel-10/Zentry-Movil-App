package zentry.back.api.core.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ReportRequest {

    @NotNull
    private Integer userId;
}
