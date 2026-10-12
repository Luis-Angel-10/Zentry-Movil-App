package zentry.back.api.business.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.Invoices;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Repository
public interface InvoicesRepository extends JpaRepository<Invoices, UUID> {

    List<Invoices> findByUserId(Integer userId);

    Page<Invoices> findByUserId(Integer userId, Pageable pageable);

    List<Invoices> findByTotalGreaterThanEqual(BigDecimal total);
}
