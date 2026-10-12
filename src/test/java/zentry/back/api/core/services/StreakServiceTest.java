package zentry.back.api.core.services;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import zentry.back.api.core.dtos.StreakResponse;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.core.repositories.UserStreakRepository;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Corrección "racha bugeada" (parte 1: aislamiento por usuario, no por
 * dispositivo/IP). Usa la BD real de test (H2 en modo PostgreSQL, ver
 * application-test.properties) para ejercitar el mismo camino JPA que usa
 * el endpoint real: StreakService -> UserStreakRepository -> user_streaks
 * (con user_id UNIQUE).
 *
 * Sin @Transactional a nivel de clase a propósito: cada operación de
 * StreakService ya es transaccional por sí misma (@Transactional en
 * recordActivity/getStreak), así que cada test ve el estado realmente
 * confirmado en BD, igual que lo vería una petición HTTP real.
 */
@SpringBootTest
@ActiveProfiles("test")
@DisplayName("StreakService — racha independiente por usuario (no por dispositivo/IP)")
class StreakServiceTest {

    @Autowired
    private StreakService streakService;
    @Autowired
    private UserRepository userRepo;
    @Autowired
    private UserStreakRepository streakRepo;

    private User userA;
    private User userB;

    @BeforeEach
    void setUp() {
        String suffix = UUID.randomUUID().toString().substring(0, 8);
        userA = userRepo.save(User.builder()
                .username("userA_" + suffix)
                .email("userA_" + suffix + "@zentry.test")
                .password("x")
                .verified(true)
                .onboardingCompleted(true)
                .build());
        userB = userRepo.save(User.builder()
                .username("userB_" + suffix)
                .email("userB_" + suffix + "@zentry.test")
                .password("x")
                .verified(true)
                .onboardingCompleted(true)
                .build());
    }

    @AfterEach
    void tearDown() {
        streakRepo.findByUserId(userA.getId()).ifPresent(streakRepo::delete);
        streakRepo.findByUserId(userB.getId()).ifPresent(streakRepo::delete);
        userRepo.delete(userA);
        userRepo.delete(userB);
    }

    @Test
    @DisplayName("TEST 1/2/9: la actividad de A sólo modifica la racha de A, la de B queda intacta")
    void activityOfUserA_onlyAffectsUserA() {
        streakService.recordActivity(userA.getId());

        StreakResponse a = streakService.getStreak(userA.getEmail());
        StreakResponse b = streakService.getStreak(userB.getEmail());

        assertThat(a.getCurrentStreak()).isEqualTo(1);
        assertThat(a.getActiveToday()).isTrue();

        // La racha de B nunca se creó: getStreak la reporta en 0 sin
        // persistir nada (ver StreakService.getStreak, orElse(builder...)).
        assertThat(b.getCurrentStreak()).isEqualTo(0);
        assertThat(b.getActiveToday()).isFalse();
        assertThat(streakRepo.findByUserId(userB.getId())).isEmpty();
    }

    @Test
    @DisplayName("TEST 2/9 (inverso): la actividad de B sólo modifica la racha de B, la de A queda intacta")
    void activityOfUserB_onlyAffectsUserB() {
        streakService.recordActivity(userA.getId());
        streakService.recordActivity(userB.getId());
        streakService.recordActivity(userB.getId()); // mismo día: no debe duplicar el avance

        StreakResponse a = streakService.getStreak(userA.getEmail());
        StreakResponse b = streakService.getStreak(userB.getEmail());

        assertThat(a.getCurrentStreak()).isEqualTo(1);
        assertThat(b.getCurrentStreak()).isEqualTo(1);
    }

    @Test
    @DisplayName("TEST 3: /streaks/me autenticado como A y como B devuelve la racha propia de cada uno")
    void getStreak_byIdentifier_returnsOwnDataPerUser() {
        streakService.recordActivity(userA.getId());

        StreakResponse byEmailA = streakService.getStreak(userA.getEmail());
        StreakResponse byUsernameA = streakService.getStreak(userA.getHandle());
        StreakResponse b = streakService.getStreak(userB.getEmail());

        assertThat(byEmailA.getUserId()).isEqualTo(userA.getId());
        assertThat(byUsernameA.getUserId()).isEqualTo(userA.getId());
        assertThat(b.getUserId()).isEqualTo(userB.getId());
        assertThat(b.getUserId()).isNotEqualTo(byEmailA.getUserId());
    }

    @Test
    @DisplayName("TEST 4: la misma cuenta consultada dos veces (simulando 2 dispositivos) recibe idéntica racha desde el backend")
    void sameAccount_fromTwoSimulatedDevices_seesSameStreak() {
        streakService.recordActivity(userA.getId());

        // Dos lecturas independientes con el mismo identificador de cuenta,
        // como si fueran dos peticiones HTTP desde dos dispositivos distintos
        // (el backend no recibe ni usa IP/deviceId en ningún punto de este
        // camino: identifier -> User -> UserStreak, ver resolveUser()).
        StreakResponse fromPhone = streakService.getStreak(userA.getEmail());
        StreakResponse fromTablet = streakService.getStreak(userA.getEmail());

        assertThat(fromPhone.getCurrentStreak()).isEqualTo(fromTablet.getCurrentStreak());
        assertThat(fromPhone.getLastActivityDate()).isEqualTo(fromTablet.getLastActivityDate());
        assertThat(fromPhone.getActiveToday()).isEqualTo(fromTablet.getActiveToday());
    }

    @Test
    @DisplayName("TEST 5: GET /streaks/me (getStreak) es de solo lectura, NO incrementa ni crea racha")
    void getStreak_isReadOnly_doesNotIncrementOrCreate() {
        // Antes de cualquier actividad: sólo consultar no debe crear fila.
        streakService.getStreak(userA.getEmail());
        streakService.getStreak(userA.getEmail());
        streakService.getStreak(userA.getEmail());
        assertThat(streakRepo.findByUserId(userA.getId())).isEmpty();

        // Con racha ya iniciada: consultar repetidamente no debe seguir
        // subiendo currentStreak (eso sólo lo hace recordActivity).
        streakService.recordActivity(userA.getId());
        streakService.getStreak(userA.getEmail());
        streakService.getStreak(userA.getEmail());
        StreakResponse after = streakService.getStreak(userA.getEmail());

        assertThat(after.getCurrentStreak()).isEqualTo(1);
        assertThat(streakRepo.findByUserId(userA.getId()).orElseThrow().getCurrentStreak()).isEqualTo(1);
    }
}
