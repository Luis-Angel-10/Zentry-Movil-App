package zentry.back.api.core.models;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "user_settings", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class UserSettings {

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "privacidad", length = 20)
    private String privacidad;
}
