package zentry.back.api.core.dtos;

import java.time.LocalDateTime;
import java.util.List;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommunityResponse {

    private Integer id;
    private String slug;
    private String nombre;
    private String descripcion;
    private String imageUrl;
    private String avatarUrl;
    private String bannerUrl;
    private String categoria;
    private Integer creatorId;
    private String ownerUsername;
    private List<String> rules;
    private Integer membersCount;
    private Boolean isJoined;
    private LocalDateTime createdAt;
}
