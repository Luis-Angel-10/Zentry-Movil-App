package zentry.back.api.core.models;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "project_members", schema = "zentry_core")
@IdClass(ProjectMember.ProjectMemberId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class ProjectMember {

    @Id
    @Column(name = "project_id")
    private Long projectId;

    // username o email del colaborador (mismo identificador que Project.createdBy)
    @Id
    @Column(name = "username")
    private String username;

    // "OWNER" o "COLLABORATOR"
    private String role;

    @Column(name = "joined_at")
    private LocalDateTime joinedAt;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class ProjectMemberId implements Serializable {
        private Long projectId;
        private String username;
    }
}
