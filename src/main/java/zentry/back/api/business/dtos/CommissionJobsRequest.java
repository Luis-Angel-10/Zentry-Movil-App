package zentry.back.api.business.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommissionJobsRequest {
    private Integer userId;
    private String descripcion;
}
