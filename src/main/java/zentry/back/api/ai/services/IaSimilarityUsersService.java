package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaSimilarityUsersRequest;
import zentry.back.api.ai.dtos.IaSimilarityUsersResponse;
import zentry.back.api.ai.models.IaSimilarityUsers;
import zentry.back.api.ai.models.IaSimilarityUsersId;
import zentry.back.api.ai.repositories.IaSimilarityUsersRepository;
import zentry.back.api.ai.mappers.IaMappers;

@Service
@SuppressWarnings("null")
public class IaSimilarityUsersService {

    private final IaSimilarityUsersRepository repo;

    public IaSimilarityUsersService(IaSimilarityUsersRepository repo) {
        this.repo = repo;
    }

    public Page<IaSimilarityUsersResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaSimilarityUsersResponse getById(Integer user1, Integer user2) {
        IaSimilarityUsersId id = new IaSimilarityUsersId(user1, user2);
        IaSimilarityUsers entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SimilarityUsers not found"));
        return IaMappers.toResponse(entity);
    }

    public IaSimilarityUsersResponse create(IaSimilarityUsersRequest request) {
        if (repo.existsByUser1AndUser2(request.getUser1(), request.getUser2())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Similarity record already exists for these users");
        }
        IaSimilarityUsers entity = IaSimilarityUsers.builder()
                .user1(request.getUser1())
                .user2(request.getUser2())
                .score(request.getScore())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaSimilarityUsersResponse update(Integer user1, Integer user2, IaSimilarityUsersRequest request) {
        IaSimilarityUsersId id = new IaSimilarityUsersId(user1, user2);
        IaSimilarityUsers entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SimilarityUsers not found"));
        entity.setScore(request.getScore());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer user1, Integer user2) {
        IaSimilarityUsersId id = new IaSimilarityUsersId(user1, user2);
        IaSimilarityUsers entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SimilarityUsers not found"));
        repo.delete(entity);
    }
}
