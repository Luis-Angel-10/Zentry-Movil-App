package zentry.back.api.core.dtos;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ProjectMemberResponse {
    private Long projectId;
    private String username;
    private String role;
    private LocalDateTime joinedAt;
}
