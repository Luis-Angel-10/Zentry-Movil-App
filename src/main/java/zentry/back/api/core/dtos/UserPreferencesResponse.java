package zentry.back.api.core.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserPreferencesResponse {

    private Integer userId;
    private String config;
}
