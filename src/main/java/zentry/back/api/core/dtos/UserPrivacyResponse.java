package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserPrivacyResponse {

    private Integer userId;
    private String nivel;
}
