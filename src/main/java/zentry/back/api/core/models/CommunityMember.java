package zentry.back.api.core.models;
import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "community_members", schema = "zentry_core")
@IdClass(CommunityMember.CommunityMemberId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class CommunityMember {

    @Id
    @Column(name = "community_id")
    private Integer communityId;

    @Column(name = "role", length = 20)
    private String role;

    @Column(name = "joined_at", updatable = false)
    private LocalDateTime joinedAt;

    @lombok.Builder.Default
    @Column(name = "notifications_enabled", columnDefinition = "boolean default true")
    private Boolean notificationsEnabled = true;

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class CommunityMemberId implements java.io.Serializable {
        private Integer communityId;
        private Integer userId;
    }
}
