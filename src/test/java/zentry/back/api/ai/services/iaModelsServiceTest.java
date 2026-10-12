package zentry.back.api.ai.services;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaModelsRequest;
import zentry.back.api.ai.dtos.IaModelsResponse;
import zentry.back.api.ai.models.IaModels;
import zentry.back.api.ai.repositories.IaModelsRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("IaModelsService")
@SuppressWarnings("all")
class IaModelsServiceTest {

    @Mock
    private IaModelsRepository repo;

    @InjectMocks
    private IaModelsService service;

    private UUID existingId;
    private IaModels sampleModel;

    @BeforeEach
    void setUp() {
        existingId = UUID.randomUUID();
        sampleModel = IaModels.builder()
                .id(existingId)
                .nombre("GPT-4")
                .build();
    }

    // ═══════════════════════════════════════════════════════════════════════
    // list
    // ═══════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("list()")
    class ListTests {

        @Test
        @DisplayName("returns a page of responses mapped from entities")
        void returnsPageOfResponses() {
            Pageable pageable = PageRequest.of(0, 10);
            Page<IaModels> page = new PageImpl<>(List.of(sampleModel));
            when(repo.findAll(pageable)).thenReturn(page);

            Page<IaModelsResponse> result = service.list(pageable);

            assertThat(result).isNotEmpty();
            assertThat(result.getContent().get(0).getNombre()).isEqualTo("GPT-4");
            assertThat(result.getContent().get(0).getId()).isEqualTo(existingId);
        }

        @Test
        @DisplayName("returns empty page when no models exist")
        void returnsEmptyPage() {
            Pageable pageable = PageRequest.of(0, 10);
            when(repo.findAll(pageable)).thenReturn(Page.empty());

            Page<IaModelsResponse> result = service.list(pageable);

            assertThat(result).isEmpty();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // getById
    // ═══════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("getById()")
    class GetByIdTests {

        @Test
        @DisplayName("returns response when model exists")
        void returnsResponseWhenFound() {
            when(repo.findById(existingId)).thenReturn(Optional.of(sampleModel));

            IaModelsResponse result = service.getById(existingId);

            assertThat(result.getId()).isEqualTo(existingId);
            assertThat(result.getNombre()).isEqualTo("GPT-4");
        }

        @Test
        @DisplayName("throws 404 when model does not exist")
        void throws404WhenNotFound() {
            UUID unknown = UUID.randomUUID();
            when(repo.findById(unknown)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.getById(unknown))
                    .isInstanceOf(ResponseStatusException.class)
                    .satisfies(ex -> assertThat(((ResponseStatusException) ex).getStatusCode())
                            .isEqualTo(HttpStatus.NOT_FOUND));
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // create
    // ═══════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("create()")
    class CreateTests {

        @Test
        @DisplayName("persists and returns response when name is unique")
        void createsSuccessfully() {
            IaModelsRequest request = new IaModelsRequest();
            request.setNombre("Claude-3");

            IaModels saved = IaModels.builder().id(UUID.randomUUID()).nombre("Claude-3").build();

            when(repo.existsByNombre("Claude-3")).thenReturn(false);
            when(repo.save(any(IaModels.class))).thenReturn(saved);

            IaModelsResponse result = service.create(request);

            assertThat(result.getNombre()).isEqualTo("Claude-3");
            verify(repo).save(any(IaModels.class));
        }

        @Test
        @DisplayName("throws 400 when model name already exists")
        void throws400WhenDuplicate() {
            IaModelsRequest request = new IaModelsRequest();
            request.setNombre("GPT-4");

            when(repo.existsByNombre("GPT-4")).thenReturn(true);

            assertThatThrownBy(() -> service.create(request))
                    .isInstanceOf(ResponseStatusException.class)
                    .satisfies(ex -> assertThat(((ResponseStatusException) ex).getStatusCode())
                            .isEqualTo(HttpStatus.BAD_REQUEST));

            verify(repo, never()).save(any());
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // update
    // ═══════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("update()")
    class UpdateTests {

        @Test
        @DisplayName("updates nombre and returns updated response")
        void updatesSuccessfully() {
            IaModelsRequest request = new IaModelsRequest();
            request.setNombre("GPT-4-turbo");

            IaModels updated = IaModels.builder().id(existingId).nombre("GPT-4-turbo").build();

            when(repo.findById(existingId)).thenReturn(Optional.of(sampleModel));
            when(repo.save(sampleModel)).thenReturn(updated);

            IaModelsResponse result = service.update(existingId, request);

            assertThat(result.getNombre()).isEqualTo("GPT-4-turbo");
        }

        @Test
        @DisplayName("throws 404 when model to update does not exist")
        void throws404WhenNotFound() {
            UUID unknown = UUID.randomUUID();
            when(repo.findById(unknown)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.update(unknown, new IaModelsRequest()))
                    .isInstanceOf(ResponseStatusException.class)
                    .satisfies(ex -> assertThat(((ResponseStatusException) ex).getStatusCode())
                            .isEqualTo(HttpStatus.NOT_FOUND));
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // delete
    // ═══════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("delete()")
    class DeleteTests {

        @Test
        @DisplayName("deletes model when it exists")
        void deletesSuccessfully() {
            when(repo.findById(existingId)).thenReturn(Optional.of(sampleModel));

            service.delete(existingId);

            verify(repo).delete(sampleModel);
        }

        @Test
        @DisplayName("throws 404 when model to delete does not exist")
        void throws404WhenNotFound() {
            UUID unknown = UUID.randomUUID();
            when(repo.findById(unknown)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.delete(unknown))
                    .isInstanceOf(ResponseStatusException.class)
                    .satisfies(ex -> assertThat(((ResponseStatusException) ex).getStatusCode())
                            .isEqualTo(HttpStatus.NOT_FOUND));

            verify(repo, never()).delete(any());
        }
    }
}
