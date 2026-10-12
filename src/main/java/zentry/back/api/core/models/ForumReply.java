package zentry.back.api.core.models;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "forum_replies", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class ForumReply {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "thread_id")
    private Integer threadId;

    @Column(name = "author_user_id")
    private Integer authorUserId;

    @Column(length = 2000)
    private String content;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
