package zentry.back.api.business.models;
import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "order_items", schema = "zentry_business")
@IdClass(OrderItems.OrderItemsId.class)
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor

public class OrderItems {

    @Id
    @Column(name = "order_id")
    private UUID orderId;

    @Id
    @Column(name = "product_id")
    private UUID productId;

    @Column(name = "cantidad")
    private Integer cantidad;

    // Clase interna para la clave primaria compuesta
    @lombok.EqualsAndHashCode
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class OrderItemsId implements java.io.Serializable {
        private UUID orderId;
        private UUID productId;
    }
}
