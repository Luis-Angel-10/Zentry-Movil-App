package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AuditLogResponse {

    private Integer id;
    private String accion;
}
