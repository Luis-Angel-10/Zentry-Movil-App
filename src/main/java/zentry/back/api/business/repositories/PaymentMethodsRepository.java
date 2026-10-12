package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.PaymentMethods;

import java.util.List;
import java.util.UUID;

@Repository
public interface PaymentMethodsRepository extends JpaRepository<PaymentMethods, UUID> {

    List<PaymentMethods> findByUserId(Integer userId);

    List<PaymentMethods> findByMetodo(String metodo);

    boolean existsByUserIdAndMetodo(Integer userId, String metodo);
}
