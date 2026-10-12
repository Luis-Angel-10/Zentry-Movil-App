package zentry.back.api.ai.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class IaPromptsRequest {
    private Integer userId;
    private String prompt;
}
