package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class LoginHistoryResponse {

    private Integer id;
    private Integer userId;
    private String ip;
}
