package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.FriendshipRequest;
import zentry.back.api.core.dtos.FriendshipResponse;
import zentry.back.api.core.models.Friendship;
import zentry.back.api.core.models.Friendship.FriendshipId;
import zentry.back.api.core.repositories.FriendshipRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class FriendshipService {

    private final FriendshipRepository repo;

    public FriendshipService(FriendshipRepository repo) {
        this.repo = repo;
    }

    public Page<FriendshipResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public FriendshipResponse getById(Integer user1, Integer user2) {
        FriendshipId id = new FriendshipId(user1, user2);
        Friendship entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Friendship not found"));
        return CoreMappers.toResponse(entity);
    }

    public FriendshipResponse create(FriendshipRequest request) {
        FriendshipId id = new FriendshipId(request.getUser1(), request.getUser2());
        if (repo.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Friendship already exists");
        }
        Friendship entity = Friendship.builder()
                .user1(request.getUser1())
                .user2(request.getUser2())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer user1, Integer user2) {
        FriendshipId id = new FriendshipId(user1, user2);
        Friendship entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Friendship not found"));
        repo.delete(entity);
    }
}
