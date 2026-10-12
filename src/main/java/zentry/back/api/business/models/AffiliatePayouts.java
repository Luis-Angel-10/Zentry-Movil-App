package zentry.back.api.business.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Entity 
@Table(name = "affiliate_payouts", schema = "zentry_business")      
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor 

public class AffiliatePayouts {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "affiliate_id", nullable = false)
    private UUID affiliateId;

    @Column(name = "amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;
    
}
