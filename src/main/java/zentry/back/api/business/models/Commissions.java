package zentry.back.api.business.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "commissions", schema = "zentry_business")        
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor 
public class Commissions {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;


    @Column(name = "porcentaje", nullable = false, precision = 10, scale = 2)
    private BigDecimal porcentaje;
}


