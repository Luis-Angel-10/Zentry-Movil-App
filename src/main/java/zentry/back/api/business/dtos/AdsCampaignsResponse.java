package zentry.back.api.business.dtos;

import lombok.*;
import java.util.UUID;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AdsCampaignsResponse {
    private UUID id;
    private Integer userId;
    private String nombre;
    private String headline;
    private String body;
    private String imageUrl;
    private String linkUrl;
    private String ctaLabel;
    private String placement;
    private Boolean isActive;
}
