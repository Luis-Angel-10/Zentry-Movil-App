package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.Wallets;

import java.math.BigDecimal;
import java.util.Optional;

@Repository
public interface WalletsRepository extends JpaRepository<Wallets, Integer> {

    Optional<Wallets> findByUserId(Integer userId);

    boolean existsByUserId(Integer userId);

    java.util.List<Wallets> findByBalanceGreaterThanEqual(BigDecimal balance);
}
