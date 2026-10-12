package zentry.back.api.core.services;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.PostResponse;
import zentry.back.api.core.models.Post;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.PostLikeRepository;
import zentry.back.api.core.repositories.PostRepository;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.core.repositories.UserStreakRepository;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;

/**
 * Corrección del HTTP 500 "No EntityManager with actual transaction
 * available for current thread - cannot reliably process 'remove' call" en
 * POST /api/core/posts/{id}/like.
 *
 * A propósito SIN @Transactional a nivel de clase: si lo tuviera, el propio
 * test envolvería a PostService.toggleLike en la transacción del test (que
 * Spring hace participar, propagación REQUIRED) y el bug original — la
 * ausencia de @Transactional en el método — quedaría oculto, porque el
 * borrado derivado (`deleteByPostIdAndUserId`) tendría igualmente una
 * transacción activa prestada por el test. Aquí cada llamada a
 * `postService.toggleLike(...)` corre con su propia transacción real,
 * exactamente como una petición HTTP real contra la BD real de test (H2 en
 * modo PostgreSQL).
 */
@SpringBootTest
@ActiveProfiles("test")
@DisplayName("PostService.toggleLike — corrección HTTP 500 al quitar like + consistencia con la racha")
class PostServiceLikeTest {

    @Autowired
    private PostService postService;
    @Autowired
    private UserRepository userRepo;
    @Autowired
    private PostRepository postRepo;
    @Autowired
    private PostLikeRepository postLikeRepo;
    @Autowired
    private UserStreakRepository streakRepo;

    @MockitoBean
    private NotificationService notificationService;

    private User liker;
    private User author;
    private Post post;

    @BeforeEach
    void setUp() {
        Mockito.reset(notificationService);
        String suffix = UUID.randomUUID().toString().substring(0, 8);
        liker = userRepo.save(User.builder()
                .username("liker_" + suffix)
                .email("liker_" + suffix + "@zentry.test")
                .password("x")
                .verified(true)
                .onboardingCompleted(true)
                .build());
        author = userRepo.save(User.builder()
                .username("author_" + suffix)
                .email("author_" + suffix + "@zentry.test")
                .password("x")
                .verified(true)
                .onboardingCompleted(true)
                .build());
        post = postRepo.save(Post.builder()
                .userId(author.getId())
                .title("Obra de prueba " + suffix)
                .build());
    }

    @AfterEach
    void tearDown() {
        postLikeRepo.findByPostIdAndUserId(post.getId(), liker.getId()).ifPresent(postLikeRepo::delete);
        streakRepo.findByUserId(liker.getId()).ifPresent(streakRepo::delete);
        postRepo.delete(post);
        userRepo.delete(liker);
        userRepo.delete(author);
    }

    @Test
    @DisplayName("TEST 6: dar like funciona y actualiza la racha del que da like")
    void like_succeedsAndUpdatesLikerStreak() {
        PostResponse response = postService.toggleLike(post.getId(), liker.getHandle());

        assertThat(response.getLiked()).isTrue();
        assertThat(response.getLikesCount()).isEqualTo(1);
        assertThat(streakRepo.findByUserId(liker.getId())).isPresent();
        assertThat(streakRepo.findByUserId(liker.getId()).get().getCurrentStreak()).isEqualTo(1);
    }

    @Test
    @DisplayName("TEST 7 (repro original del HTTP 500): quitar el like NO lanza excepción")
    void unlike_doesNotThrow_regressionForHttp500() {
        postService.toggleLike(post.getId(), liker.getHandle()); // like

        // Este es exactamente el camino que producía el 500 original:
        // postLikeRepo.deleteByPostIdAndUserId(...) sin @Transactional en
        // toggleLike.
        PostResponse[] result = new PostResponse[1];
        assertThatCode(() -> result[0] = postService.toggleLike(post.getId(), liker.getHandle())) // unlike
                .doesNotThrowAnyException();

        assertThat(result[0].getLiked()).isFalse();
        assertThat(result[0].getLikesCount()).isEqualTo(0);
        assertThat(postLikeRepo.existsByPostIdAndUserId(post.getId(), liker.getId())).isFalse();
    }

    @Test
    @DisplayName("TEST 8: like -> unlike -> like repetidamente no genera HTTP 500 ni deja estado inconsistente")
    void repeatedToggle_neverThrowsAndStaysConsistent() {
        for (int i = 0; i < 5; i++) {
            int iteration = i;
            assertThatCode(() -> postService.toggleLike(post.getId(), liker.getHandle()))
                    .as("iteración %d", iteration)
                    .doesNotThrowAnyException();
        }
        // 5 toggles a partir de "sin like": termina en estado "con like".
        boolean finalLiked = postLikeRepo.existsByPostIdAndUserId(post.getId(), liker.getId());
        assertThat(finalLiked).isTrue();
        assertThat(postLikeRepo.countByPostId(post.getId())).isEqualTo(1);
    }

    @Test
    @DisplayName("TEST 9: dar like NO modifica la racha del autor de la publicación (otro usuario)")
    void like_doesNotAffectAuthorsStreak() {
        postService.toggleLike(post.getId(), liker.getHandle());

        assertThat(streakRepo.findByUserId(liker.getId())).isPresent();
        assertThat(streakRepo.findByUserId(author.getId())).isEmpty();
    }

    @Test
    @DisplayName("TEST 10: si la operación de like falla, no queda ni el like ni la racha a medias (atomicidad)")
    void failureDuringLike_rollsBackBothLikeAndStreak() {
        // NotificationService.notify() se llama al FINAL de la rama "dar
        // like", después de guardar el PostLike y de actualizar
        // racha/misión/logro. Forzarlo a fallar aquí simula cualquier fallo
        // tardío dentro de la misma operación: con @Transactional en
        // toggleLike, Spring revierte TODA la transacción (like + racha)
        // porque RuntimeException dispara rollback por defecto.
        Mockito.doThrow(new RuntimeException("fallo simulado"))
                .when(notificationService)
                .notify(anyInt(), anyString(), anyString(), anyString(), any(), anyInt());

        assertThatThrownBy(() -> postService.toggleLike(post.getId(), liker.getHandle()))
                .isInstanceOf(RuntimeException.class);

        // Ni el like ni la racha deben haber quedado guardados.
        assertThat(postLikeRepo.existsByPostIdAndUserId(post.getId(), liker.getId())).isFalse();
        assertThat(streakRepo.findByUserId(liker.getId())).isEmpty();
    }

    @Test
    @DisplayName("Publicación inexistente: 404 antes de tocar likes o racha (sin efectos parciales)")
    void likeOnMissingPost_throws404AndTouchesNothing() {
        int missingPostId = post.getId() + 999_999;

        assertThatThrownBy(() -> postService.toggleLike(missingPostId, liker.getHandle()))
                .isInstanceOf(ResponseStatusException.class);

        assertThat(streakRepo.findByUserId(liker.getId())).isEmpty();
    }
}
