package zentry.back.api.ai.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaFeedbackRequest {
    private Integer userId;
    private String comentario;
}
