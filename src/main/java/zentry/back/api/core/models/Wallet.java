package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "wallets", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Wallet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    private BigDecimal balance; // Saldo de Zentry Coins (ZC)

    private String activePlanId; // "free", "pro", "vip"

    private LocalDateTime nextBillingDate;

    @PrePersist
    public void init() {
        if (balance == null) balance = BigDecimal.valueOf(100.00); // Saldo demo inicial
        if (activePlanId == null) activePlanId = "free";
        if (nextBillingDate == null) nextBillingDate = LocalDateTime.now().plusDays(30);
    }
}
