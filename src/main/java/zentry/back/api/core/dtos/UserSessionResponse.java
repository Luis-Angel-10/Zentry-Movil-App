package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserSessionResponse {

    private Integer id;
    private Integer userId;
    private String token;
}
