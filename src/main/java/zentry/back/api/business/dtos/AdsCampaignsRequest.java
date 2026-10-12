package zentry.back.api.business.dtos;

import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class AdsCampaignsRequest {
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
