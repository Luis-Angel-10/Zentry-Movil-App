package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.SubcategoryRequest;
import zentry.back.api.core.dtos.SubcategoryResponse;
import zentry.back.api.core.models.Subcategory;
import zentry.back.api.core.repositories.SubcategoryRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class SubcategoryService {

    private final SubcategoryRepository repo;

    public SubcategoryService(SubcategoryRepository repo) {
        this.repo = repo;
    }

    public Page<SubcategoryResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public SubcategoryResponse getById(Integer id) {
        Subcategory entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Subcategory not found"));
        return CoreMappers.toResponse(entity);
    }

    public SubcategoryResponse create(SubcategoryRequest request) {
        Subcategory entity = Subcategory.builder()
                .categoriaId(request.getCategoriaId())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public SubcategoryResponse update(Integer id, SubcategoryRequest request) {
        Subcategory entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Subcategory not found"));
        entity.setCategoriaId(request.getCategoriaId());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        Subcategory entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Subcategory not found"));
        repo.delete(entity);
    }
}
