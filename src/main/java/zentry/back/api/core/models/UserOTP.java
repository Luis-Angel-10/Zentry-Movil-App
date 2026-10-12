package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_otps")
@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class UserOTP {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer userId;
    
    private String code;

    private LocalDateTime expirationTime;

    @Builder.Default
    private Integer attempts = 0;
}
