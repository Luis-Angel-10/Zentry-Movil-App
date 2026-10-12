package zentry.back.api.core.services;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import java.util.List;
import java.util.stream.Collectors;
import zentry.back.api.core.dtos.ProfileRequest;
import zentry.back.api.core.dtos.ProfileResponse;
import zentry.back.api.core.models.Profile;
import zentry.back.api.core.models.User;
import zentry.back.api.core.models.Follow;
import zentry.back.api.core.repositories.FollowRepository;
import zentry.back.api.core.repositories.ProfileRepository;
import zentry.back.api.core.repositories.UserRepository;
import org.springframework.web.multipart.MultipartFile;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import lombok.Getter;
import lombok.AllArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

@Service
@SuppressWarnings("null")
public class ProfileService {

    private final ProfileRepository profileRepo;
    private final UserRepository userRepo;

    private final FollowRepository followRepo;
    private final GamificationEventService gamificationEventService;
    private final NotificationService notificationService;

    public ProfileService(ProfileRepository profileRepo, UserRepository userRepo, FollowRepository followRepo,
                           GamificationEventService gamificationEventService, NotificationService notificationService) {
        this.profileRepo = profileRepo;
        this.userRepo = userRepo;
        this.notificationService = notificationService;
        this.followRepo = followRepo;
        this.gamificationEventService = gamificationEventService;
    }

    private User resolveUser(String identifier) {
        if (identifier == null || identifier.isBlank()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Identificador no proporcionado");
        }
        var byUsernameOrEmail = userRepo.findByUsernameOrEmail(identifier, identifier);
        if (byUsernameOrEmail.isPresent()) return byUsernameOrEmail.get();

        var byEmail = userRepo.findByEmail(identifier);
        if (byEmail.isPresent()) return byEmail.get();

        var byUsername = userRepo.findByUsername(identifier);
        if (byUsername.isPresent()) return byUsername.get();

        var byEmailPrefix = userRepo.findByEmailStartingWith(identifier + "@");
        if (byEmailPrefix.isPresent()) return byEmailPrefix.get();

        var byEmailPrefixRaw = userRepo.findByEmailStartingWith(identifier);
        if (byEmailPrefixRaw.isPresent()) return byEmailPrefixRaw.get();

        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
    }

    public ProfileResponse getProfileByUsername(String identifier) {
        return getProfileByUsername(identifier, null);
    }

    public ProfileResponse getProfileByUserId(Integer userId, String currentUsername) {
        User user = userRepo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        Profile profile = profileRepo.findByUserId(user.getId())
                .orElse(new Profile());

        boolean isFollowing = false;
        if (currentUsername != null && !currentUsername.isBlank()) {
            User currentUser = userRepo.findByUsernameOrEmail(currentUsername, currentUsername)
                    .orElseGet(() -> userRepo.findByEmail(currentUsername).orElse(null));
            if (currentUser != null) {
                isFollowing = followRepo.existsByFollowerAndFollowing(currentUser.getId(), user.getId());
            }
        }

        long followersCount = followRepo.countByFollowing(user.getId());
        long followingCount = followRepo.countByFollower(user.getId());

        ProfileResponse response = mapToResponse(user, profile);
        response.setFollowersCount((int) followersCount);
        response.setFollowingCount((int) followingCount);
        response.setIsFollowing(isFollowing);

        return response;
    }

    public ProfileResponse getProfileByUsername(String identifier, String currentUsername) {
        User user = resolveUser(identifier);

        Profile profile = profileRepo.findByUserId(user.getId())
                .orElse(new Profile());

        boolean isFollowing = false;
        if (currentUsername != null && !currentUsername.isBlank()) {
            User currentUser = userRepo.findByUsernameOrEmail(currentUsername, currentUsername)
                    .orElseGet(() -> userRepo.findByEmail(currentUsername).orElse(null));
            if (currentUser != null) {
                isFollowing = followRepo.existsByFollowerAndFollowing(currentUser.getId(), user.getId());
            }
        }

        long followersCount = followRepo.countByFollowing(user.getId());
        long followingCount = followRepo.countByFollower(user.getId());

        ProfileResponse response = mapToResponse(user, profile);
        response.setFollowersCount((int) followersCount);
        response.setFollowingCount((int) followingCount);
        response.setIsFollowing(isFollowing);

        return response;
    }

    @Getter
    @AllArgsConstructor
    public static class FollowResult {
        private final boolean following;
        private final int followersCount;

        public boolean isFollowing() {
            return following;
        }

        public int getNewFollowersCount() {
            return followersCount;
        }
    }

    @Transactional
    public FollowResult toggleFollowUser(String followerIdentifier, String targetIdentifier) {
        User followerUser = userRepo.findByUsernameOrEmail(followerIdentifier, followerIdentifier)
                .orElseGet(() -> userRepo.findByEmailStartingWith(followerIdentifier + "@")
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                                "Usuario seguidor no encontrado")));

        User targetUser = userRepo.findByUsernameOrEmail(targetIdentifier, targetIdentifier)
                .orElseGet(() -> userRepo.findByEmailStartingWith(targetIdentifier + "@")
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                                "Usuario a seguir no encontrado")));

        if (followerUser.getId().equals(targetUser.getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No puedes seguirte a ti mismo");
        }

        boolean alreadyFollowing = followRepo.existsByFollowerAndFollowing(followerUser.getId(), targetUser.getId());
        boolean isFollowing;
        if (alreadyFollowing) {
            followRepo.deleteByFollowerAndFollowing(followerUser.getId(), targetUser.getId());
            isFollowing = false;
        } else {
            followRepo.save(Follow.builder()
                    .follower(followerUser.getId())
                    .following(targetUser.getId())
                    .build());
            isFollowing = true;

            gamificationEventService.recordMissionProgress(followerUser.getId(), "follow_users", 1);

            Profile followerProfile = profileRepo.findByUserId(followerUser.getId()).orElse(null);
            notificationService.notify(
                    targetUser.getId(),
                    "follow",
                    "@" + followerUser.getHandle() + " comenzó a seguirte",
                    followerUser.getHandle(),
                    followerProfile != null ? followerProfile.getAvatarUrl() : null,
                    followerUser.getId()
            );
        }

        long followersCount = followRepo.countByFollowing(targetUser.getId());
        return new FollowResult(isFollowing, (int) followersCount);
    }

    @Transactional
    public boolean toggleFollow(String followerIdentifier, String targetIdentifier) {
        return toggleFollowUser(followerIdentifier, targetIdentifier).isFollowing();
    }

    public Profile findOrCreateByUsername(String usernameOrEmail) {
        User user = resolveUser(usernameOrEmail);

        return profileRepo.findByUserId(user.getId())
                .orElseGet(() -> {
                    Profile newP = Profile.builder().userId(user.getId()).build();
                    return profileRepo.save(newP);
                });
    }

    @Transactional
    public ProfileResponse updateProfile(String emailOrUsername, ProfileRequest request) {
        return updateMyProfile(emailOrUsername, request);
    }

    @Transactional
    public ProfileResponse updateProfileWithFiles(String emailOrUsername, ProfileRequest request) {
        return updateMyProfile(emailOrUsername, request);
    }

    @Transactional
    public ProfileResponse updateMyProfile(String emailOrUsername, ProfileRequest request) {
        User user = resolveUser(emailOrUsername);

        if (request.getUsername() != null && !request.getUsername().isBlank()) {
            user.setUsername(request.getUsername());
            userRepo.save(user);
        }

        Profile profile = findOrCreateByUsername(emailOrUsername);

        if (request.getName() != null && !request.getName().isBlank())
            profile.setName(request.getName());
        if (request.getDiscipline() != null)
            profile.setDiscipline(request.getDiscipline());
        if (request.getLocation() != null)
            profile.setLocation(request.getLocation());
        if (request.getBio() != null)
            profile.setBio(request.getBio());
            
        if (request.getArtisticName() != null)
            profile.setArtisticName(request.getArtisticName());
            
        if (request.getExperienceLevel() != null) {
            profile.setExperienceLevel(request.getExperienceLevel());
            if (profile.getRank() == null) {
                profile.setRank("Bronce");
            }
        }
        
        if (request.getRank() != null)
            profile.setRank(request.getRank());


        if (request.getAvatarUrl() != null && !request.getAvatarUrl().isBlank()) {
            if (request.getAvatarUrl().startsWith("data:")) {
                String savedAvatar = saveBase64Image(request.getAvatarUrl(), "avatar");
                if (savedAvatar != null) profile.setAvatarUrl(savedAvatar);
            } else {
                profile.setAvatarUrl(request.getAvatarUrl());
            }
        }
        if (request.getBannerUrl() != null && !request.getBannerUrl().isBlank()) {
            if (request.getBannerUrl().startsWith("data:")) {
                String savedBanner = saveBase64Image(request.getBannerUrl(), "banner");
                if (savedBanner != null) profile.setBannerUrl(savedBanner);
            } else {
                profile.setBannerUrl(request.getBannerUrl());
            }
        }

        if (request.getAvatar() != null && !request.getAvatar().isEmpty()) {
            String avatarUrl = saveImage(request.getAvatar(), "profiles");
            if (avatarUrl != null) {
                profile.setAvatarUrl(avatarUrl);
            }
        }

        if (request.getBanner() != null && !request.getBanner().isEmpty()) {
            String bannerUrl = saveImage(request.getBanner(), "profiles");
            if (bannerUrl != null) {
                profile.setBannerUrl(bannerUrl);
            }
        }

        if (request.getSpecialties() != null)
            profile.setSpecialties(request.getSpecialties());

        if (request.getBirthDate() != null && !request.getBirthDate().isBlank()) {
            try {
                profile.setBirthDate(java.time.LocalDate.parse(request.getBirthDate()));
            } catch (Exception ignored) {}
        }

        if (Boolean.TRUE.equals(request.getOnboardingCompleted())) {
            profile.setOnboardingCompleted(true);
            user.setOnboardingCompleted(true);
            userRepo.save(user);
        }

        Profile savedProfile = profileRepo.save(profile);

        gamificationEventService.recordMissionProgress(user.getId(), "update_profile", 1);
        gamificationEventService.recordAchievementProgress(user.getId(), "complete_profile", 1);

        long followersCount = followRepo.countByFollowing(user.getId());
        long followingCount = followRepo.countByFollower(user.getId());

        ProfileResponse response = mapToResponse(user, savedProfile);
        response.setFollowersCount((int) followersCount);
        response.setFollowingCount((int) followingCount);
        response.setIsFollowing(false);
        return response;
    }

    public String saveBase64Image(String base64Data, String type) {
        if (base64Data == null || base64Data.isBlank()) return null;
        if (!base64Data.startsWith("data:")) return base64Data;
        try {
            Path uploadDir = Paths.get("uploads", "profiles");
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            String base64Image = base64Data;
            String extension = ".png";
            if (base64Data.contains(",")) {
                String[] parts = base64Data.split(",");
                String header = parts[0].toLowerCase();
                if (header.contains("image/jpeg") || header.contains("image/jpg")) {
                    extension = ".jpg";
                } else if (header.contains("image/webp")) {
                    extension = ".webp";
                } else if (header.contains("image/gif")) {
                    extension = ".gif";
                }
                base64Image = parts[1];
            }

            byte[] decodedBytes = java.util.Base64.getDecoder().decode(base64Image.trim());
            String fileName = type + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;
            Path targetPath = uploadDir.resolve(fileName);
            Files.write(targetPath, decodedBytes);

            return "/uploads/profiles/" + fileName;
        } catch (Exception e) {
            return null;
        }
    }

    // MÉTODO SEGURO PARA GUARDAR EN DISCO
    public String saveImage(MultipartFile file, String subfolder) {
        if (file == null || file.isEmpty()) {
            return null;
        }
        try {
            Path uploadDir = Paths.get("uploads", subfolder);
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            String extension = ".png";
            String originalFilename = file.getOriginalFilename();
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }

            String fileName = UUID.randomUUID().toString() + extension;
            Path targetPath = uploadDir.resolve(fileName);

            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
            return "/uploads/" + subfolder + "/" + fileName;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "No se pudo guardar la imagen: " + e.getMessage(), e);
        }
    }

    public List<ProfileResponse> searchProfiles(String query) {
        List<Profile> profiles = profileRepo.findByNameContainingIgnoreCase(query);
        return profiles.stream().map(profile -> {
            User user = userRepo.findById(profile.getUserId()).orElse(new User());
            return mapToResponse(user, profile);
        }).toList();
    }

    private ProfileResponse mapToResponse(User user, Profile profile) {
        String displayUsername = user.getHandle() != null ? user.getHandle() : user.getEmail().split("@")[0];
        return ProfileResponse.builder()
                .username(user.getHandle())
                .name(profile.getName() != null ? profile.getName() : displayUsername)
                .artisticName(profile.getArtisticName())
                .discipline(profile.getDiscipline())
                .specialties(profile.getSpecialties())
                .birthDate(profile.getBirthDate() != null ? profile.getBirthDate().toString() : null)
                .onboardingCompleted(Boolean.TRUE.equals(profile.getOnboardingCompleted()) || Boolean.TRUE.equals(user.getOnboardingCompleted()))
                .experienceLevel(profile.getExperienceLevel())
                .rank(profile.getRank())
                .location(profile.getLocation())
                .bio(profile.getBio())
                .avatarUrl(profile.getAvatarUrl())
                .bannerUrl(profile.getBannerUrl())
                .isPrivate(Boolean.TRUE.equals(profile.getIsPrivate()))
                .showSavedPosts(!Boolean.FALSE.equals(profile.getShowSavedPosts()))
                .showLikedPosts(!Boolean.FALSE.equals(profile.getShowLikedPosts()))
                .followersCount(0)
                .followingCount(0)
                .isFollowing(false)
                .createdAt(profile.getCreatedAt())
                .build();
    }
}
