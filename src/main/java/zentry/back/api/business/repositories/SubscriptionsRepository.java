package zentry.back.api.business.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.Subscriptions;

import java.util.List;
import java.util.UUID;

@Repository
public interface SubscriptionsRepository extends JpaRepository<Subscriptions, UUID> {

    List<Subscriptions> findByUserId(Integer userId);

    List<Subscriptions> findByPlanId(UUID planId);

    Page<Subscriptions> findByUserId(Integer userId, Pageable pageable);

    boolean existsByUserId(Integer userId);

    boolean existsByUserIdAndPlanId(Integer userId, UUID planId);

    void deleteByUserId(Integer userId);
}
