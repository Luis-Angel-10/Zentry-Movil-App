package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserSettingsResponse {

    private Integer userId;
    private String privacidad;
}
