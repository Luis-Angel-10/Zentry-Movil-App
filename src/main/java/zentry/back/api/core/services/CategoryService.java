package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.CategoryRequest;
import zentry.back.api.core.dtos.CategoryResponse;
import zentry.back.api.core.models.Category;
import zentry.back.api.core.repositories.CategoryRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class CategoryService {

    private final CategoryRepository repo;

    public CategoryService(CategoryRepository repo) {
        this.repo = repo;
    }

    public Page<CategoryResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public CategoryResponse getById(Integer id) {
        Category entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found"));
        return CoreMappers.toResponse(entity);
    }

    public CategoryResponse create(CategoryRequest request) {
        Category entity = Category.builder()
                .nombre(request.getNombre())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public CategoryResponse update(Integer id, CategoryRequest request) {
        Category entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found"));
        entity.setNombre(request.getNombre());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        Category entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found"));
        repo.delete(entity);
    }
}
