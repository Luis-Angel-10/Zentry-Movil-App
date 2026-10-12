package zentry.back.api.core.repositories;

import zentry.back.api.core.models.UserAchievement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserAchievementRepository extends JpaRepository<UserAchievement, Integer> {
    List<UserAchievement> findByUserId(Integer userId);
    boolean existsByUserIdAndAchievementId(Integer userId, Integer achievementId);
    Optional<UserAchievement> findByUserIdAndAchievementId(Integer userId, Integer achievementId);
}
