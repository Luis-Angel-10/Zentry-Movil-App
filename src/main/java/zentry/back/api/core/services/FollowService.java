package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.FollowRequest;
import zentry.back.api.core.dtos.FollowResponse;
import zentry.back.api.core.models.Follow;
import zentry.back.api.core.models.Follow.FollowId;
import zentry.back.api.core.repositories.FollowRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class FollowService {

    private final FollowRepository repo;
    private final zentry.back.api.core.repositories.UserRepository userRepo;
    private final zentry.back.api.core.repositories.ProfileRepository profileRepo;

    public FollowService(FollowRepository repo, 
                         zentry.back.api.core.repositories.UserRepository userRepo,
                         zentry.back.api.core.repositories.ProfileRepository profileRepo) {
        this.repo = repo;
        this.userRepo = userRepo;
        this.profileRepo = profileRepo;
    }

    public Page<FollowResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public FollowResponse getById(Integer follower, Integer following) {
        FollowId id = new FollowId(follower, following);
        Follow entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Follow not found"));
        return CoreMappers.toResponse(entity);
    }

    public FollowResponse create(FollowRequest request) {
        FollowId id = new FollowId(request.getFollower(), request.getFollowing());
        if (repo.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Follow already exists");
        }
        Follow entity = Follow.builder()
                .follower(request.getFollower())
                .following(request.getFollowing())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer follower, Integer following) {
        FollowId id = new FollowId(follower, following);
        Follow entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Follow not found"));
        repo.delete(entity);
    }
    
    public java.util.List<zentry.back.api.core.dtos.ProfileResponse> getFollowers(String username) {
        zentry.back.api.core.models.User user = userRepo.findByUsername(username)
            .orElseGet(() -> userRepo.findByEmail(username).orElse(null));
        if (user == null) return java.util.Collections.emptyList();
        
        return repo.findByFollowing(user.getId()).stream().map(f -> {
            zentry.back.api.core.models.User followerUser = userRepo.findById(f.getFollower()).orElse(new zentry.back.api.core.models.User());
            zentry.back.api.core.models.Profile followerProfile = profileRepo.findByUserId(followerUser.getId()).orElse(new zentry.back.api.core.models.Profile());
            return mapToResponse(followerUser, followerProfile);
        }).toList();
    }
    
    public java.util.List<zentry.back.api.core.dtos.ProfileResponse> getFollowing(String username) {
        zentry.back.api.core.models.User user = userRepo.findByUsername(username)
            .orElseGet(() -> userRepo.findByEmail(username).orElse(null));
        if (user == null) return java.util.Collections.emptyList();
        
        return repo.findByFollower(user.getId()).stream().map(f -> {
            zentry.back.api.core.models.User followingUser = userRepo.findById(f.getFollowing()).orElse(new zentry.back.api.core.models.User());
            zentry.back.api.core.models.Profile followingProfile = profileRepo.findByUserId(followingUser.getId()).orElse(new zentry.back.api.core.models.Profile());
            return mapToResponse(followingUser, followingProfile);
        }).toList();
    }
    
    private zentry.back.api.core.dtos.ProfileResponse mapToResponse(zentry.back.api.core.models.User user, zentry.back.api.core.models.Profile profile) {
        String displayUsername = user.getHandle() != null ? user.getHandle() : user.getEmail().split("@")[0];
        return zentry.back.api.core.dtos.ProfileResponse.builder()
                .username(user.getHandle())
                .name(profile.getName() != null ? profile.getName() : displayUsername)
                .artisticName(profile.getArtisticName())
                .avatarUrl(profile.getAvatarUrl())
                .build();
    }
}
