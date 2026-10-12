package zentry.back.api.core.models;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "user_preferences", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class UserPreferences {

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "config", columnDefinition = "TEXT")
    private String config;
}
