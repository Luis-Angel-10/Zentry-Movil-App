package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "project_likes", schema = "zentry_core")
@IdClass(ProjectLike.ProjectLikeId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class ProjectLike {

    @Id
    @Column(name = "project_id")
    private Long projectId;

    @Id
    @Column(name = "username")
    private String username;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class ProjectLikeId implements Serializable {
        private Long projectId;
        private String username;
    }
}
