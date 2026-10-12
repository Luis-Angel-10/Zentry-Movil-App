package zentry.back.api.core.services;

import org.springframework.stereotype.Service;
import zentry.back.api.core.dtos.AchievementResponse;
import zentry.back.api.core.models.Achievement;
import zentry.back.api.core.models.UserAchievement;
import zentry.back.api.core.repositories.AchievementRepository;
import zentry.back.api.core.repositories.UserAchievementRepository;
import zentry.back.api.global.mappers;

import jakarta.annotation.PostConstruct;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class AchievementService {

    private final AchievementRepository achievementRepo;
    private final UserAchievementRepository userAchievementRepo;

    public AchievementService(AchievementRepository achievementRepo, UserAchievementRepository userAchievementRepo) {
        this.achievementRepo = achievementRepo;
        this.userAchievementRepo = userAchievementRepo;
    }

    @PostConstruct
    public void seedAchievements() {
        Set<String> existingTitles = achievementRepo.findAll().stream()
                .map(Achievement::getTitle)
                .collect(Collectors.toSet());

        List<Achievement> catalog = List.of(
            achievement("Primer Trazo", "Crea tu primera obra o boceto en el Estudio Creativo Multimodal", 50, "🎨", "COMMON", "creation", "create_first_project", 1, false, null),
            achievement("Voz en Zentry", "Envía tus primeros 5 mensajes directos y comenta publicaciones", 50, "💬", "COMMON", "social", "send_messages", 5, false, null),
            achievement("Ojo Curador", "Reacciona con likes a más de 25 obras en la plataforma", 75, "👁️", "COMMON", "social", "like_posts", 25, false, null),
            achievement("Identidad Blindada", "Completa tu perfil, avatar, biografía y personaliza tu seguridad", 80, "🛡️", "COMMON", "reputation", "complete_profile", 1, false, null),
            achievement("Alma de la Comunidad", "Únete a 3 comunidades y publica un tema de debate", 100, "🏛️", "RARE", "community", "join_communities", 3, false, null),
            achievement("Arquitecto Digital", "Crea y exporta 5 proyectos completos desde el Estudio", 150, "⚡", "RARE", "creation", "export_projects", 5, false, null),
            achievement("Conexión Creativa", "Consigue 10 amigos o seguidores en tu red social", 120, "🤝", "RARE", "social", "friends_count", 10, false, null),
            achievement("En Llamas", "Completa todas las misiones diarias durante 3 días seguidos", 200, "🔥", "RARE", "mastery", "mission_streak_days", 3, false, null),
            achievement("Inspiración Nocturna", "Crea o edita contenido en el Estudio durante la noche (00:00 - 05:00)", 100, "🌙", "RARE", "creation", "edit_at_night", 1, false, null),
            achievement("Billetera Dorada", "Alcanza un saldo acumulado de más de 500 Zentry Coins (ZC)", 250, "🪙", "EPIC", "reputation", "wallet_balance", 500, false, null),
            achievement("Maestro Polímata", "Publica proyectos que involucren al menos 3 disciplinas diferentes", 250, "🎭", "EPIC", "mastery", "disciplines_count", 3, false, null),
            achievement("Obra Maestra", "Consigue que una de tus obras alcance 30 reacciones de la comunidad", 300, "🌟", "EPIC", "reputation", "post_reactions", 30, false, null),
            achievement("Sinergia Co-Creativa", "Trabaja como colaborador en un proyecto compartido", 200, "🚀", "EPIC", "community", "project_collab", 1, false, null),
            achievement("Leyenda de Zentry", "Alcanza más de 50 seguidores, 15 obras publicadas y 1,000 ZC", 500, "👑", "LEGENDARY", "reputation", "legend_combo", 1, false, null),
            achievement("Gran Maestro de Misiones", "Completa exitosamente 25 misiones diarias del portal", 400, "🏆", "LEGENDARY", "mastery", "missions_completed", 25, false, null),
            achievement("Pionero Multiversal", "Forma parte de la primera generación de creadores Zentry 2026", 350, "🌌", "LEGENDARY", "reputation", "early_adopter", 1, false, null),
            achievement("El Secreto de Zentry", "Descubriste el portal cuántico y activaste el tema secreto de la red.", 500, "🔮", "MYSTERIOUS", "mystery", "secret_cosmic_portal", 1, true, "Una puerta dimensional espera a quienes exploren más allá de lo visible..."),
            achievement("Infiltrado del Vacío", "Enviaste un mensaje directo encriptado en el canal seguro.", 300, "🕶️", "MYSTERIOUS", "mystery", "secret_void_hacker", 1, true, "Los mensajes nocturnos transmiten más que simples palabras..."),
            achievement("Decodificador Cósmico", "Exploraste creadores de 5 categorías artísticas en una sola sesión.", 350, "🧩", "MYSTERIOUS", "mystery", "secret_multiverse_decoder", 5, true, "Solo quien camina por todos los mundos artísticos revela este sello."),
            achievement("Sobrecarga de Inspiración", "Completaste 4 misiones diarias en tiempo récord antes del mediodía.", 400, "⚡", "MYSTERIOUS", "mystery", "secret_speed_crafter", 1, true, "La velocidad del relámpago premia a la mente sin descanso."),
            achievement("Viajero Astral", "Mantuviste tu presencia en línea durante 7 días consecutivos en Zentry.", 600, "🌠", "MYSTERIOUS", "mystery", "secret_astral_traveler", 7, true, "La constancia infinita forja los lazos con las estrellas."),
            achievement("Metamorfosis Digital", "Personalizaste completamente tu foto de perfil, portada y biografía.", 200, "🎭", "MYSTERIOUS", "mystery", "secret_holographic_mask", 1, true, "Cambia tu rostro, revela tu verdadera aura creativa."),
            achievement("Llave de los Secretos", "Reclamaste más de 3 recompensas de misiones en un solo día.", 250, "🗝️", "MYSTERIOUS", "mystery", "secret_master_key", 3, true, "Tres cofres abiertos revelan la llave oculta."),
            achievement("Resonancia Armónica", "Conectaste con amigos y recibiste solicitudes de co-creación.", 300, "🎵", "MYSTERIOUS", "mystery", "secret_harmonic_resonance", 1, true, "Cuando dos frecuencias creativas vibran juntas, la melodía despierta.")
        );

        catalog.stream()
                .filter(a -> !existingTitles.contains(a.getTitle()))
                .forEach(achievementRepo::save);
    }

    private static Achievement achievement(String title, String description, int rewardCoins, String iconUrl,
                                            String rarity, String category, String requirementType, int requirementValue,
                                            boolean isSecret, String secretHint) {
        return Achievement.builder()
                .title(title)
                .description(description)
                .rewardCoins(rewardCoins)
                .iconUrl(iconUrl)
                .rarity(rarity)
                .category(category)
                .requirementType(requirementType)
                .requirementValue(requirementValue)
                .isSecret(isSecret)
                .secretHint(secretHint)
                .build();
    }

    public List<AchievementResponse> listAll() {
        return achievementRepo.findAll().stream()
                .map(mappers::toResponse)
                .collect(Collectors.toList());
    }

    public List<AchievementResponse> listForUser(Integer userId) {
        Map<Integer, UserAchievement> unlockedByAchievementId = userAchievementRepo.findByUserId(userId).stream()
                .collect(Collectors.toMap(UserAchievement::getAchievementId, ua -> ua));

        return achievementRepo.findAll().stream()
                .map(achievement -> {
                    AchievementResponse response = mappers.toResponse(achievement);
                    UserAchievement progress = unlockedByAchievementId.get(achievement.getId());
                    if (progress != null) {
                        response.setProgress(progress.getProgress());
                        response.setUnlocked(progress.getUnlockedAt() != null);
                        response.setUnlockedAt(progress.getUnlockedAt());
                    } else {
                        response.setProgress(0);
                    }
                    return response;
                })
                .collect(Collectors.toList());
    }
}
