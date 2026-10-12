package zentry.back.api.business.mappers;

import zentry.back.api.business.dtos.*;
import zentry.back.api.business.models.*;
import java.util.*;

public final class BusinessMappers {
    private BusinessMappers() {}

    public static WalletsResponse toResponse(Wallets entity) {
        if (entity == null) return null;
        return WalletsResponse.builder()
                .userId(entity.getUserId())
                .balance(entity.getBalance())
                .build();
    }

    public static CartResponse toResponse(Cart entity) {
        if (entity == null) return null;
        return CartResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .build();
    }

    public static CartItemsResponse toResponse(CartItems entity) {
        if (entity == null) return null;
        return CartItemsResponse.builder()
                .cartId(entity.getCartId())
                .productId(entity.getProductId())
                .cantidad(entity.getCantidad())
                .build();
    }

    public static SubscriptionsResponse toResponse(Subscriptions entity) {
        if (entity == null) return null;
        return SubscriptionsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .planId(entity.getPlanId())
                .build();
    }

    public static SubscriptionPlansResponse toResponse(SubscriptionPlans entity) {
        if (entity == null) return null;
        return SubscriptionPlansResponse.builder()
                .id(entity.getId())
                .name(entity.getName())
                .precio(entity.getPrecio())
                .description(entity.getDescription())
                .features(entity.getFeatures())
                .build();
    }

    public static PaymentMethodsResponse toResponse(PaymentMethods entity) {
        if (entity == null) return null;
        return PaymentMethodsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .metodo(entity.getMetodo())
                .build();
    }

    public static PaymentsResponse toResponse(Payments entity) {
        if (entity == null) return null;
        return PaymentsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .paymentMethodId(entity.getPaymentMethodId())
                .amount(entity.getAmount())
                .build();
    }

    public static TransactionsResponse toResponse(Transactions entity) {
        if (entity == null) return null;
        return TransactionsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .amount(entity.getAmount())
                .build();
    }

    public static WalletTransactionsResponse toResponse(WalletTransactions entity) {
        if (entity == null) return null;
        return WalletTransactionsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .amount(entity.getAmount())
                .build();
    }

    public static InvoicesResponse toResponse(Invoices entity) {
        if (entity == null) return null;
        return InvoicesResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .total(entity.getTotal())
                .build();
    }

    public static InvoicesItemsResponse toResponse(InvoicesItems entity) {
        if (entity == null) return null;
        return InvoicesItemsResponse.builder()
                .id(entity.getId())
                .invoiceId(entity.getInvoiceId())
                .descripcion(entity.getDescripcion())
                .precio(entity.getPrecio())
                .build();
    }

    public static MarketplaceOrdersResponse toResponse(MarketplaceOrders entity) {
        if (entity == null) return null;
        return MarketplaceOrdersResponse.builder()
                .id(entity.getId())
                .buyerId(entity.getBuyerId())
                .total(entity.getTotal())
                .build();
    }

    public static MarketplaceProductsResponse toResponse(MarketplaceProducts entity) {
        if (entity == null) return null;
        return MarketplaceProductsResponse.builder()
                .id(entity.getId())
                .sellerId(entity.getSellerId())
                .nombre(entity.getNombre())
                .precio(entity.getPrecio())
                .build();
    }

    public static OrderItemsResponse toResponse(OrderItems entity) {
        if (entity == null) return null;
        return OrderItemsResponse.builder()
                .orderId(entity.getOrderId())
                .productId(entity.getProductId())
                .cantidad(entity.getCantidad())
                .build();
    }

    public static PayoutsResponse toResponse(Payouts entity) {
        if (entity == null) return null;
        return PayoutsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .amount(entity.getAmount())
                .build();
    }

    public static PayoutRequestsResponse toResponse(PayoutRequests entity) {
        if (entity == null) return null;
        return PayoutRequestsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .amount(entity.getAmount())
                .build();
    }

    public static CommissionsResponse toResponse(Commissions entity) {
        if (entity == null) return null;
        return CommissionsResponse.builder()
                .id(entity.getId())
                .porcentaje(entity.getPorcentaje())
                .build();
    }

    public static CommissionJobsResponse toResponse(CommissionJobs entity) {
        if (entity == null) return null;
        return CommissionJobsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .descripcion(entity.getDescripcion())
                .build();
    }

    public static AffiliateProgramResponse toResponse(AffiliateProgram entity) {
        if (entity == null) return null;
        return AffiliateProgramResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .build();
    }

    public static AffiliatePayoutsResponse toResponse(AffiliatePayouts entity) {
        if (entity == null) return null;
        return AffiliatePayoutsResponse.builder()
                .id(entity.getId())
                .affiliateId(entity.getAffiliateId())
                .amount(entity.getAmount())
                .build();
    }

    public static DonationsResponse toResponse(Donations entity) {
        if (entity == null) return null;
        return DonationsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .amount(entity.getAmount())
                .build();
    }

    public static ContractsResponse toResponse(Contracts entity) {
        if (entity == null) return null;
        return ContractsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .detalles(entity.getDetalles())
                .build();
    }

    public static AdsCampaignsResponse toResponse(AdsCampaigns entity) {
        if (entity == null) return null;
        return AdsCampaignsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .nombre(entity.getNombre())
                .headline(entity.getHeadline())
                .body(entity.getBody())
                .imageUrl(entity.getImageUrl())
                .linkUrl(entity.getLinkUrl())
                .ctaLabel(entity.getCtaLabel())
                .placement(entity.getPlacement())
                .isActive(entity.getIsActive())
                .build();
    }

    public static AdImpressionsResponse toResponse(AdImpressions entity) {
        if (entity == null) return null;
        return AdImpressionsResponse.builder()
                .id(entity.getId())
                .campaignId(entity.getCampaignId())
                .vistas(entity.getVistas())
                .build();
    }
}
