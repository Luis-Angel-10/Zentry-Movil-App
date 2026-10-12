package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.BookmarkRequest;
import zentry.back.api.core.dtos.BookmarkResponse;
import zentry.back.api.core.models.Bookmark;
import zentry.back.api.core.repositories.BookmarkRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class BookmarkService {

    private final BookmarkRepository repo;

    public BookmarkService(BookmarkRepository repo) {
        this.repo = repo;
    }

    public Page<BookmarkResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public BookmarkResponse getById(Integer id) {
        Bookmark entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Bookmark not found"));
        return CoreMappers.toResponse(entity);
    }

    public BookmarkResponse create(BookmarkRequest request) {
        Bookmark entity = Bookmark.builder()
                .userId(request.getUserId())
                .postId(request.getPostId())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public BookmarkResponse update(Integer id, BookmarkRequest request) {
        Bookmark entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Bookmark not found"));
        entity.setUserId(request.getUserId());
        entity.setPostId(request.getPostId());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        Bookmark entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Bookmark not found"));
        repo.delete(entity);
    }
}
