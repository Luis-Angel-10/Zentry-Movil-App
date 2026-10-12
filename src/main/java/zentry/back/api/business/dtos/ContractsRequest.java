package zentry.back.api.business.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ContractsRequest {
    private Integer userId;
    private String detalles;
}
