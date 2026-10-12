package zentry.back.api.analytics.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AbTestResultRequest {

    @NotNull
    private Integer testId;

    @NotBlank
    @Size(max = 50)
    private String variant;

    private BigDecimal result;

    private Integer userId;
}
