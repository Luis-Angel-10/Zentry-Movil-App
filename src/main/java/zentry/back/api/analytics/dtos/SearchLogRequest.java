package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class SearchLogRequest {

    private Integer userId;

    @NotBlank
    private String query;
}
