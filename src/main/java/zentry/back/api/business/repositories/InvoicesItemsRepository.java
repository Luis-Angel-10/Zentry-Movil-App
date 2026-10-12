package zentry.back.api.business.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.business.models.InvoicesItems;

import java.util.List;
import java.util.UUID;

@Repository
public interface InvoicesItemsRepository extends JpaRepository<InvoicesItems, UUID> {

    List<InvoicesItems> findByInvoiceId(UUID invoiceId);

    List<InvoicesItems> findByDescripcionContainingIgnoreCase(String descripcion);

    void deleteByInvoiceId(UUID invoiceId);
}
