package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.CommentReactionRequest;
import zentry.back.api.core.dtos.CommentReactionResponse;
import zentry.back.api.core.models.CommentReaction;
import zentry.back.api.core.repositories.CommentReactionRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class CommentReactionService {

    private final CommentReactionRepository repo;

    public CommentReactionService(CommentReactionRepository repo) {
        this.repo = repo;
    }

    public Page<CommentReactionResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public CommentReactionResponse getById(Integer id) {
        CommentReaction entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CommentReaction not found"));
        return CoreMappers.toResponse(entity);
    }

    public CommentReactionResponse create(CommentReactionRequest request) {
        CommentReaction entity = CommentReaction.builder()
                .commentId(request.getCommentId())
                .userId(request.getUserId())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public CommentReactionResponse update(Integer id, CommentReactionRequest request) {
        CommentReaction entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CommentReaction not found"));
        entity.setCommentId(request.getCommentId());
        entity.setUserId(request.getUserId());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        CommentReaction entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CommentReaction not found"));
        repo.delete(entity);
    }
}
