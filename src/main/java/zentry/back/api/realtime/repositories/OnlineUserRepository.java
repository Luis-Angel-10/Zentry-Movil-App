package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.OnlineUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OnlineUserRepository extends JpaRepository<OnlineUser, Integer> {

}
