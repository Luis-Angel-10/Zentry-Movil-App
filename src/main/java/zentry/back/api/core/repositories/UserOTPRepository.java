package zentry.back.api.core.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.core.models.UserOTP;
import java.util.Optional;

@Repository
public interface UserOTPRepository extends JpaRepository<UserOTP, Long> {
    Optional<UserOTP> findByUserIdAndCode(Integer userId, String code);
    Optional<UserOTP> findByUserId(Integer userId);
    void deleteByUserId(Integer userId);
}
