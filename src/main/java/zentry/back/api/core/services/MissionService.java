package zentry.back.api.core.services;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.MissionResponse;
import zentry.back.api.core.dtos.TopupRequest;
import zentry.back.api.core.dtos.WalletResponse;
import zentry.back.api.core.models.Mission;
import zentry.back.api.core.models.UserMission;
import zentry.back.api.core.repositories.MissionRepository;
import zentry.back.api.core.repositories.UserMissionRepository;
import zentry.back.api.global.mappers;

import jakarta.annotation.PostConstruct;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class MissionService {

    private final MissionRepository missionRepo;
    private final UserMissionRepository userMissionRepo;
    private final WalletService walletService;
    private final GamificationEventService gamificationEventService;
    private final NotificationService notificationService;

    public MissionService(MissionRepository missionRepo, UserMissionRepository userMissionRepo, WalletService walletService,
                           GamificationEventService gamificationEventService, NotificationService notificationService) {
        this.missionRepo = missionRepo;
        this.userMissionRepo = userMissionRepo;
        this.walletService = walletService;
        this.gamificationEventService = gamificationEventService;
        this.notificationService = notificationService;
    }

    @PostConstruct
    public void seedMissions() {
        Set<String> existingTitles = missionRepo.findAll().stream()
                .map(Mission::getTitle)
                .collect(Collectors.toSet());

        List<Mission> catalog = List.of(
            mission("Explorador del Feed", "Reacciona a 5 publicaciones de otros creadores en el feed", "social", 10, "react_posts", 5, "Heart"),
            mission("Crítica Constructiva", "Comenta en 2 obras para dar feedback a compañeros creadores", "social", 15, "comment_posts", 2, "MessageCircle"),
            mission("Amplía tu Círculo", "Sigue a 3 nuevos artistas desde la pestaña Explorar", "exploration", 15, "follow_users", 3, "UserPlus"),
            mission("Chispa de Creación", "Abre el Estudio Creativo y genera un nuevo lienzo o proyecto", "creation", 30, "create_project", 1, "Sparkles"),
            mission("Conexión Creativa", "Envía un mensaje directo a un amigo o colaborador", "social", 15, "send_message", 1, "Send"),
            mission("Voz Comunitaria", "Visita y participa en al menos una comunidad artística", "community", 20, "visit_community", 1, "Users"),
            mission("Inspiración en Galería", "Explora y guarda o reacciona a proyectos destacados", "exploration", 15, "react_projects", 3, "Bookmark"),
            mission("Difusión Artística", "Comparte un enlace de tu perfil u obra con la comunidad", "creation", 25, "share_profile", 1, "Share2"),
            mission("Presencia Activa", "Mantén tu estado en línea y revisa tus notificaciones diarias", "streak", 10, "daily_login", 1, "Flame"),
            mission("Mente Multimodal", "Filtra y visualiza contenido de 2 disciplinas artísticas distintas", "exploration", 20, "filter_disciplines", 2, "Compass"),
            mission("Lanza tu Visión", "Crea una nueva publicación en el feed principal", "creation", 35, "create_post", 1, "Upload"),
            mission("Lazos de Co-Creación", "Envía o responde a una solicitud de amistad/colaboración", "social", 20, "friend_request", 1, "UserCheck"),
            mission("Toque de Identidad", "Actualiza o verifica tu biografía y disciplina en tu perfil", "creation", 20, "update_profile", 1, "User"),
            mission("Inmersión Total", "Explora las pestañas de Destacados, Para Ti y Siguiendo en el feed", "exploration", 15, "explore_feed_tabs", 3, "Compass")
        );

        catalog.stream()
                .filter(m -> !existingTitles.contains(m.getTitle()))
                .forEach(missionRepo::save);
    }

    private static Mission mission(String title, String description, String category, int rewardCoins,
                                    String requirementType, int requirementValue, String iconName) {
        return Mission.builder()
                .title(title)
                .description(description)
                .category(category)
                .rewardCoins(rewardCoins)
                .requirementType(requirementType)
                .requirementValue(requirementValue)
                .iconName(iconName)
                .build();
    }

    /**
     * Si el progreso guardado pertenece a un día anterior, lo reinicia para que
     * la misión vuelva a estar disponible hoy (comportamiento real de "misión diaria").
     */
    private boolean resetIfStale(UserMission um) {
        LocalDate today = LocalDate.now(java.time.ZoneOffset.UTC);
        if (um.getResetDate() != null && um.getResetDate().isEqual(today)) {
            return false;
        }
        um.setProgress(0);
        um.setIsCompleted(false);
        um.setCompletedAt(null);
        um.setResetDate(today);
        return true;
    }

    public List<MissionResponse> getUserMissions(Integer userId) {
        List<UserMission> userMissions = userMissionRepo.findByUserId(userId);
        userMissions.forEach(um -> {
            if (resetIfStale(um)) {
                userMissionRepo.save(um);
            }
        });

        Map<Integer, UserMission> progressByMissionId = userMissions.stream()
                .collect(Collectors.toMap(UserMission::getMissionId, um -> um));

        return missionRepo.findAll().stream()
                .map(mission -> {
                    MissionResponse response = mappers.toResponse(mission);
                    UserMission progress = progressByMissionId.get(mission.getId());
                    if (progress != null) {
                        response.setProgress(progress.getProgress());
                        response.setCompleted(Boolean.TRUE.equals(progress.getIsCompleted()));
                        response.setCompletedAt(progress.getCompletedAt());
                    }
                    return response;
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public MissionResponse claimMission(Integer userId, String username, Integer missionId) {
        Mission mission = missionRepo.findById(missionId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Misión no encontrada"));

        UserMission userMission = userMissionRepo.findByUserIdAndMissionId(userId, missionId)
                .orElse(null);

        if (userMission != null) {
            resetIfStale(userMission);
        }

        if (userMission != null && Boolean.TRUE.equals(userMission.getIsCompleted())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Ya reclamaste esta misión");
        }

        int currentProgress = userMission != null && userMission.getProgress() != null ? userMission.getProgress() : 0;
        if (currentProgress < mission.getRequirementValue()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Aún no completas los requisitos de esta misión");
        }

        WalletResponse wallet = walletService.topup(username,
                TopupRequest.builder().amount(BigDecimal.valueOf(mission.getRewardCoins())).build());

        LocalDateTime now = LocalDateTime.now();
        if (userMission == null) {
            userMission = UserMission.builder()
                    .userId(userId)
                    .missionId(missionId)
                    .progress(mission.getRequirementValue())
                    .isCompleted(true)
                    .completedAt(now)
                    .resetDate(LocalDate.now(java.time.ZoneOffset.UTC))
                    .build();
        } else {
            userMission.setProgress(mission.getRequirementValue());
            userMission.setIsCompleted(true);
            userMission.setCompletedAt(now);
            userMission.setResetDate(LocalDate.now(java.time.ZoneOffset.UTC));
        }
        userMissionRepo.save(userMission);

        gamificationEventService.recordAchievementProgress(userId, "missions_completed", 1);

        notificationService.notify(
                userId,
                "reward",
                "Reclamaste " + mission.getRewardCoins() + " Zentry Coins por completar \"" + mission.getTitle() + "\"",
                null,
                null,
                mission.getId()
        );

        MissionResponse response = mappers.toResponse(mission);
        response.setProgress(userMission.getProgress());
        response.setCompleted(true);
        response.setCompletedAt(now);
        return response;
    }
}
