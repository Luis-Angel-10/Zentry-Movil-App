package zentry.back.api.core.repositories;

import zentry.back.api.core.models.UserMission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserMissionRepository extends JpaRepository<UserMission, Integer> {
    List<UserMission> findByUserId(Integer userId);
    Optional<UserMission> findByUserIdAndMissionId(Integer userId, Integer missionId);
}
