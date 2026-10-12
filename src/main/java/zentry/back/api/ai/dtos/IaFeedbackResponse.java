package zentry.back.api.ai.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaFeedbackResponse {
    private UUID id;
    private Integer userId;
    private String comentario;
}
