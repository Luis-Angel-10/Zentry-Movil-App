package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository("realtimeNotificationRepository")
public interface NotificationRepository extends JpaRepository<Notification, Integer> {

}
