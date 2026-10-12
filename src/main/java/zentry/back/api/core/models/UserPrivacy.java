package zentry.back.api.core.models;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "user_privacy", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class UserPrivacy {

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "nivel", length = 20)
    private String nivel;
}
