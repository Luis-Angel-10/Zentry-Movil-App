package zentry.back.api.core.services;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import zentry.back.api.core.dtos.TopupRequest;
import zentry.back.api.core.models.Achievement;
import zentry.back.api.core.models.Mission;
import zentry.back.api.core.models.User;
import zentry.back.api.core.models.UserAchievement;
import zentry.back.api.core.models.UserMission;
import zentry.back.api.core.repositories.AchievementRepository;
import zentry.back.api.core.repositories.MissionRepository;
import zentry.back.api.core.repositories.UserAchievementRepository;
import zentry.back.api.core.repositories.UserMissionRepository;
import zentry.back.api.core.repositories.UserRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Punto central donde el resto de servicios reportan acciones reales del usuario
 * (crear post, dar like, seguir a alguien, etc.) para que las misiones y logros
 * avancen su progreso real en vez de quedar congelados en 0.
 *
 * No depende de MissionService/AchievementService a propósito, para evitar
 * dependencias circulares (esos servicios sí pueden depender de este).
 */
@Service
public class GamificationEventService {

    private final MissionRepository missionRepo;
    private final UserMissionRepository userMissionRepo;
    private final AchievementRepository achievementRepo;
    private final UserAchievementRepository userAchievementRepo;
    private final UserRepository userRepo;
    private final WalletService walletService;
    private final StreakService streakService;

    public GamificationEventService(MissionRepository missionRepo, UserMissionRepository userMissionRepo,
                                     AchievementRepository achievementRepo, UserAchievementRepository userAchievementRepo,
                                     UserRepository userRepo, WalletService walletService, StreakService streakService) {
        this.missionRepo = missionRepo;
        this.userMissionRepo = userMissionRepo;
        this.achievementRepo = achievementRepo;
        this.userAchievementRepo = userAchievementRepo;
        this.userRepo = userRepo;
        this.walletService = walletService;
        this.streakService = streakService;
    }

    @Transactional
    public void recordMissionProgress(Integer userId, String eventType, int amount) {
        if (userId == null || eventType == null || amount <= 0) return;
        streakService.recordActivity(userId);

        LocalDate today = LocalDate.now(java.time.ZoneOffset.UTC);
        List<Mission> matching = missionRepo.findByRequirementType(eventType);
        for (Mission mission : matching) {
            UserMission progress = userMissionRepo.findByUserIdAndMissionId(userId, mission.getId()).orElse(null);

            boolean isStale = progress != null && (progress.getResetDate() == null || !progress.getResetDate().isEqual(today));
            if (isStale) {
                progress.setProgress(0);
                progress.setIsCompleted(false);
                progress.setCompletedAt(null);
            }

            if (progress != null && !isStale && Boolean.TRUE.equals(progress.getIsCompleted())) {
                continue;
            }

            int current = progress != null && progress.getProgress() != null ? progress.getProgress() : 0;
            int next = Math.min(mission.getRequirementValue(), current + amount);

            if (progress == null) {
                progress = UserMission.builder()
                        .userId(userId)
                        .missionId(mission.getId())
                        .progress(next)
                        .isCompleted(false)
                        .resetDate(today)
                        .build();
            } else {
                progress.setProgress(next);
                progress.setResetDate(today);
            }
            userMissionRepo.save(progress);
        }
    }

    @Transactional
    public void recordAchievementProgress(Integer userId, String eventType, int amount) {
        applyAchievementProgress(userId, eventType, amount, false);
    }

    @Transactional
    public void setAchievementProgressAbsolute(Integer userId, String eventType, int value) {
        applyAchievementProgress(userId, eventType, value, true);
    }

    private void applyAchievementProgress(Integer userId, String eventType, int value, boolean absolute) {
        if (userId == null || eventType == null) return;

        List<Achievement> matching = achievementRepo.findByRequirementType(eventType);
        for (Achievement achievement : matching) {
            UserAchievement unlocked = userAchievementRepo.findByUserIdAndAchievementId(userId, achievement.getId()).orElse(null);
            if (unlocked != null && unlocked.getUnlockedAt() != null) {
                continue;
            }

            int current = unlocked != null && unlocked.getProgress() != null ? unlocked.getProgress() : 0;
            int next = absolute ? Math.max(current, value) : current + value;
            next = Math.min(next, achievement.getRequirementValue());
            boolean reached = next >= achievement.getRequirementValue();

            if (unlocked == null) {
                unlocked = UserAchievement.builder()
                        .userId(userId)
                        .achievementId(achievement.getId())
                        .progress(next)
                        .build();
            } else {
                unlocked.setProgress(next);
            }

            if (reached) {
                unlocked.setUnlockedAt(LocalDateTime.now());
                userAchievementRepo.save(unlocked);
                grantReward(userId, achievement.getRewardCoins());
            } else {
                userAchievementRepo.save(unlocked);
            }
        }
    }

    private void grantReward(Integer userId, Integer coins) {
        if (coins == null || coins <= 0) return;
        User user = userRepo.findById(userId).orElse(null);
        if (user == null || user.getUsername() == null) return;

        walletService.topup(user.getUsername(),
                TopupRequest.builder().amount(BigDecimal.valueOf(coins)).build());
    }
}
