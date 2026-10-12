package zentry.back.api.core.services;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zentry.back.api.core.dtos.*;
import zentry.back.api.core.models.*;
import zentry.back.api.core.repositories.*;
import zentry.back.api.core.mappers.CoreMappers;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@SuppressWarnings("null")
public class ExploreService {

    private final TrendingTopicRepository trendingRepo;
    private final UserRepository userRepo;
    private final ProfileRepository profileRepo;
    private final PostRepository postRepo;

    public ExploreService(TrendingTopicRepository trendingRepo,
                          UserRepository userRepo,
                          ProfileRepository profileRepo,
                          PostRepository postRepo) {
        this.trendingRepo = trendingRepo;
        this.userRepo = userRepo;
        this.profileRepo = profileRepo;
        this.postRepo = postRepo;
    }

    @Transactional
    public List<TrendingTopicResponse> getTrendingTopics() {
        List<TrendingTopic> list = trendingRepo.findAllByOrderByPostsCountDesc();
        if (list.isEmpty()) {
            list = seedInitialTrendingTopics();
        }
        return list.stream()
                .map(CoreMappers::toResponse)
                .collect(Collectors.toList());
    }

    public List<TrendingTopicResponse> getTrendingHistory(Integer year) {
        int targetYear = (year != null) ? year : LocalDateTime.now().getYear();
        List<TrendingTopic> list = trendingRepo.findByYearOrderByPostsCountDesc(targetYear);
        if (list.isEmpty()) {
            list = getTrendingTopics().stream()
                    .map(dto -> TrendingTopic.builder()
                            .id(dto.getId())
                            .hashtag(dto.getHashtag())
                            .category(dto.getCategory())
                            .postsCount(dto.getPostsCount())
                            .isHot(dto.getIsHot())
                            .year(targetYear)
                            .updatedAt(dto.getUpdatedAt())
                            .build())
                    .collect(Collectors.toList());
        }
        return list.stream()
                .map(CoreMappers::toResponse)
                .collect(Collectors.toList());
    }

    public UnifiedSearchResponse unifiedSearch(String query) {
        String searchKeyword = (query == null) ? "" : query.trim();

        // 1. Search Users / Profiles
        List<User> matchingUsers = userRepo.findByUsernameContainingIgnoreCaseOrEmailContainingIgnoreCase(searchKeyword, searchKeyword);
        List<ProfileResponse> users = matchingUsers.stream()
                .map(user -> {
                    Profile profile = profileRepo.findByUserId(user.getId()).orElse(new Profile());
                    return ProfileResponse.builder()
                            .username(user.getHandle())
                            .name(profile.getName() != null ? profile.getName() : user.getHandle())
                            .discipline(profile.getDiscipline())
                            .location(profile.getLocation())
                            .bio(profile.getBio())
                            .avatarUrl(profile.getAvatarUrl())
                            .bannerUrl(profile.getBannerUrl())
                            .followersCount(0)
                            .followingCount(0)
                            .createdAt(profile.getCreatedAt())
                            .build();
                })
                .collect(Collectors.toList());

        // 2. Search Arts / Posts
        List<Post> matchingPosts = postRepo.findByTitleContainingIgnoreCaseOrContenidoContainingIgnoreCaseOrderByCreatedAtDesc(searchKeyword, searchKeyword);
        List<PostResponse> arts = matchingPosts.stream()
                .map(post -> {
                    User author = userRepo.findById(post.getUserId()).orElse(new User());
                    Profile profile = profileRepo.findByUserId(author.getId()).orElse(new Profile());
                    return PostResponse.builder()
                            .id(post.getId())
                            .authorUsername(author.getHandle())
                            .authorName(profile.getName() != null ? profile.getName() : author.getHandle())
                            .authorAvatar(profile.getAvatarUrl())
                            .title(post.getTitle())
                            .contenido(post.getContenido())
                            .mediaUrls(post.getImageUrl() != null ? List.of(post.getImageUrl()) : new ArrayList<>())
                            .tags(post.getTools() != null ? post.getTools() : new ArrayList<>())
                            .likesCount(0)
                            .commentsCount(0)
                            .createdAt(post.getCreatedAt())
                            .build();
                })
                .collect(Collectors.toList());

        // 3. Search Trending Topics
        List<TrendingTopic> matchingTrends;
        if (searchKeyword.isEmpty()) {
            matchingTrends = trendingRepo.findAllByOrderByPostsCountDesc();
        } else {
            matchingTrends = trendingRepo.findByHashtagContainingIgnoreCaseOrCategoryContainingIgnoreCaseOrderByPostsCountDesc(searchKeyword, searchKeyword);
        }
        if (matchingTrends.isEmpty() && searchKeyword.isEmpty()) {
            matchingTrends = seedInitialTrendingTopics();
        }

        List<TrendingTopicResponse> trending = matchingTrends.stream()
                .map(CoreMappers::toResponse)
                .collect(Collectors.toList());

        return UnifiedSearchResponse.builder()
                .users(users)
                .arts(arts)
                .trending(trending)
                .build();
    }

    private List<TrendingTopic> seedInitialTrendingTopics() {
        int currentYear = LocalDateTime.now().getYear();
        List<TrendingTopic> demo = List.of(
                TrendingTopic.builder().hashtag("#Cyberpunk2099").category("Arte 3D & VFX").postsCount(14200L).isHot(true).year(currentYear).updatedAt(LocalDateTime.now()).build(),
                TrendingTopic.builder().hashtag("#UIUXDesign").category("Diseño UI/UX").postsCount(9800L).isHot(true).year(currentYear).updatedAt(LocalDateTime.now()).build(),
                TrendingTopic.builder().hashtag("#DigitalArt2026").category("Arte Digital").postsCount(7500L).isHot(false).year(currentYear).updatedAt(LocalDateTime.now()).build(),
                TrendingTopic.builder().hashtag("#ConceptArt").category("Ilustración & Concept").postsCount(5300L).isHot(true).year(currentYear).updatedAt(LocalDateTime.now()).build(),
                TrendingTopic.builder().hashtag("#VFXMotion").category("Animación 3D").postsCount(3100L).isHot(false).year(currentYear).updatedAt(LocalDateTime.now()).build()
        );
        return trendingRepo.saveAll(demo);
    }
}
