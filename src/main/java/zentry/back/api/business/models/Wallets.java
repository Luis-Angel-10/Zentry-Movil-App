package zentry.back.api.business.models;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import zentry.back.api.core.models.User;

@Entity
@Table(name = "wallets", schema = "zentry_business")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Wallets {

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @Column(name = "balance", nullable = false, precision = 10, scale = 2)
    private BigDecimal balance;
}
