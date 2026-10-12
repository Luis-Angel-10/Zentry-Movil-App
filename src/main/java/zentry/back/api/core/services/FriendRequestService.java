package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.FriendRequestRequest;
import zentry.back.api.core.dtos.FriendRequestResponse;
import zentry.back.api.core.models.FriendRequest;
import zentry.back.api.core.repositories.FriendRequestRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class FriendRequestService {

    private final FriendRequestRepository repo;

    public FriendRequestService(FriendRequestRepository repo) {
        this.repo = repo;
    }

    public Page<FriendRequestResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public FriendRequestResponse getById(Integer id) {
        FriendRequest entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FriendRequest not found"));
        return CoreMappers.toResponse(entity);
    }

    public FriendRequestResponse create(FriendRequestRequest request) {
        FriendRequest entity = FriendRequest.builder()
                .user1(request.getUser1())
                .user2(request.getUser2())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public FriendRequestResponse update(Integer id, FriendRequestRequest request) {
        FriendRequest entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FriendRequest not found"));
        entity.setUser1(request.getUser1());
        entity.setUser2(request.getUser2());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        FriendRequest entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FriendRequest not found"));
        repo.delete(entity);
    }
}
