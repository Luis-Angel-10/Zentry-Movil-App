package zentry.back.api.core.dtos;

import org.springframework.web.multipart.MultipartFile;
import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ProfileRequest {

    @JsonAlias({"displayName", "display_name", "fullName", "full_name"})
    private String name;
    private String username;
    
    private String displayName;
    private String discipline;
    private String location;
    private String bio;
    
    private String artisticName;
    private String experienceLevel;
    private String rank;
    private String specialties;
    private String birthDate;
    private Boolean onboardingCompleted;
    
    @JsonAlias({"avatar_url", "photo", "image"})
    private String avatarUrl;
    
    @JsonAlias({"banner_url", "cover", "coverUrl", "cover_url"})
    private String bannerUrl;

    private MultipartFile avatar;
    private MultipartFile banner;

    @JsonAlias({"is_private", "private"})
    private Boolean isPrivate;

    @JsonAlias({"show_saved_posts"})
    private Boolean showSavedPosts;

    @JsonAlias({"show_liked_posts"})
    private Boolean showLikedPosts;

    public String getName() {
        if (name != null && !name.isBlank()) return name;
        if (displayName != null && !displayName.isBlank()) return displayName;
        return null;
    }
}

