package zentry.back.api.core.models;
import java.time.LocalDateTime;

import org.springframework.web.multipart.MultipartFile;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "profiles", schema = "zentry_core")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Profile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", unique = true, nullable = false)
    private Integer userId;

    @Column(name = "bio", columnDefinition = "TEXT")
    private String bio;

    @Column(name = "name")
    private String name;

    @Column(name = "artistic_name")
    private String artisticName;


    @Column(name = "discipline")
    private String discipline;

    @Column(name = "specialties", columnDefinition = "TEXT")
    private String specialties;

    @Column(name = "birth_date")
    private java.time.LocalDate birthDate;

    @Column(name = "onboarding_completed", columnDefinition = "boolean default false")
    @Builder.Default
    private Boolean onboardingCompleted = false;

    @Column(name = "experience_level")
    private String experienceLevel;

    @Column(name = "rank")
    private String rank;


    @Column(name = "location")
    private String location;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "banner_url")
    private String bannerUrl;

    @Column(name = "is_private", columnDefinition = "boolean default false")
    @Builder.Default
    private Boolean isPrivate = false;

    @Column(name = "show_saved_posts", columnDefinition = "boolean default true")
    @Builder.Default
    private Boolean showSavedPosts = true;

    @Column(name = "show_liked_posts", columnDefinition = "boolean default true")
    @Builder.Default
    private Boolean showLikedPosts = true;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
