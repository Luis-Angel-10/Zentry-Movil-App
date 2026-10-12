package zentry.back.api.business.models;
import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;
import zentry.back.api.core.models.User;

@Entity
@Table(name = "ads_campaigns", schema = "zentry_business")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class AdsCampaigns {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @Column(name = "nombre", length = 100, nullable = false)
    private String nombre;

    @Column(name = "headline", length = 150)
    private String headline;

    @Column(name = "body", length = 300)
    private String body;

    @Column(name = "image_url", length = 1000)
    private String imageUrl;

    @Column(name = "link_url", length = 1000)
    private String linkUrl;

    @Column(name = "cta_label", length = 50)
    private String ctaLabel;

    // Dónde se muestra: FEED, SIDEBAR o BOTH
    @Column(name = "placement", length = 20)
    @Builder.Default
    private String placement = "BOTH";

    @Builder.Default
    @Column(name = "is_active", columnDefinition = "boolean default true")
    private Boolean isActive = true;
}
