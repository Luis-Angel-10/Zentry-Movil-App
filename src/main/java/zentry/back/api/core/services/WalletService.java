package zentry.back.api.core.services;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import zentry.back.api.core.dtos.*;
import zentry.back.api.core.models.*;
import zentry.back.api.core.repositories.*;
import zentry.back.api.core.mappers.CoreMappers;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@SuppressWarnings("null")
public class WalletService {

    private final WalletRepository walletRepo;
    private final WalletTransactionRepository txRepo;
    private final UserRepository userRepo;
    private final GamificationEventService gamificationEventService;

    public WalletService(WalletRepository walletRepo, WalletTransactionRepository txRepo, UserRepository userRepo,
                          @org.springframework.context.annotation.Lazy GamificationEventService gamificationEventService) {
        this.walletRepo = walletRepo;
        this.txRepo = txRepo;
        this.userRepo = userRepo;
        this.gamificationEventService = gamificationEventService;
    }

    @jakarta.annotation.PostConstruct
    public void injectDemoCoins() {
        try {
            userRepo.findByEmail("dani12@gmail.com").ifPresent(user -> {
                String targetName = user.getHandle() != null ? user.getHandle() : user.getEmail();
                Wallet wallet = getOrCreateWallet(targetName);
                wallet.setBalance(new BigDecimal("5000.00"));
                walletRepo.save(wallet);

                if (user.getUsername() != null) {
                    Wallet wUser = getOrCreateWallet(user.getUsername());
                    wUser.setBalance(new BigDecimal("5000.00"));
                    walletRepo.save(wUser);
                }

                walletRepo.findByUsername("dani12@gmail.com").ifPresent(w -> {
                    w.setBalance(new BigDecimal("5000.00"));
                    walletRepo.save(w);
                });
            });
        } catch (Exception ignored) {}
    }

    private void trackWalletBalanceAchievement(String username, BigDecimal balance) {
        userRepo.findByEmail(username).ifPresent(u ->
                gamificationEventService.setAchievementProgressAbsolute(u.getId(), "wallet_balance", balance.intValue()));
    }

    public WalletResponse getWallet(String username) {
        Wallet wallet = getOrCreateWallet(username);
        List<WalletTransaction> transactions = txRepo.findByUsernameOrderByCreatedAtDesc(username);
        return CoreMappers.toResponse(wallet, transactions);
    }

    @Transactional
    public WalletResponse subscribe(String username, SubscribeRequest request) {
        Wallet wallet = getOrCreateWallet(username);
        String planId = request.getPlanId() != null ? request.getPlanId().toLowerCase() : "free";
        String cycle = request.getCycle() != null ? request.getCycle().toLowerCase() : "monthly";

        BigDecimal cost = calculatePlanCost(planId, cycle);

        if (wallet.getBalance().compareTo(cost) < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Saldo insuficiente en Zentry Coins para adquirir el plan " + planId.toUpperCase());
        }

        if (cost.compareTo(BigDecimal.ZERO) > 0) {
            wallet.setBalance(wallet.getBalance().subtract(cost));
            txRepo.save(WalletTransaction.builder()
                    .username(username)
                    .type(TransactionType.EGRESO)
                    .amount(cost)
                    .description("Suscripción a Plan " + planId.toUpperCase() + " (" + cycle + ")")
                    .createdAt(LocalDateTime.now())
                    .build());
        }

        wallet.setActivePlanId(planId);
        int daysToAdd = "annual".equalsIgnoreCase(cycle) ? 365 : 30;
        wallet.setNextBillingDate(LocalDateTime.now().plusDays(daysToAdd));
        walletRepo.save(wallet);

        return getWallet(username);
    }

    @Transactional
    public WalletResponse topup(String username, TopupRequest request) {
        Wallet wallet = getOrCreateWallet(username);
        BigDecimal amount = request.getAmount();

        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El monto de recarga debe ser mayor a 0 ZC");
        }

        wallet.setBalance(wallet.getBalance().add(amount));
        walletRepo.save(wallet);

        txRepo.save(WalletTransaction.builder()
                .username(username)
                .type(TransactionType.RECARGA)
                .amount(amount)
                .description("Recarga de " + amount + " Zentry Coins (ZC)")
                .createdAt(LocalDateTime.now())
                .build());

        trackWalletBalanceAchievement(username, wallet.getBalance());

        return getWallet(username);
    }

    @Transactional
    public WalletResponse transfer(String senderUsername, TransferRequest request) {
        String recipient = request.getRecipientUsername();
        BigDecimal amount = request.getAmount();

        if (recipient == null || recipient.trim().equalsIgnoreCase(senderUsername.trim())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No puedes transferir Zentry Coins a ti mismo");
        }

        User recipientUser = userRepo.findByUsername(recipient)
                .orElseGet(() -> userRepo.findByEmail(recipient)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "El usuario destinatario no existe")));

        String actualRecipientUsername = recipientUser.getUsername();
        Wallet senderWallet = getOrCreateWallet(senderUsername);

        if (senderWallet.getBalance().compareTo(amount) < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Saldo insuficiente para realizar la transferencia");
        }

        Wallet recipientWallet = getOrCreateWallet(actualRecipientUsername);

        // Descontar del emisor
        senderWallet.setBalance(senderWallet.getBalance().subtract(amount));
        walletRepo.save(senderWallet);

        txRepo.save(WalletTransaction.builder()
                .username(senderUsername)
                .type(TransactionType.EGRESO)
                .amount(amount)
                .description("Transferencia enviada a " + actualRecipientUsername)
                .createdAt(LocalDateTime.now())
                .build());

        // Acreditar al receptor
        recipientWallet.setBalance(recipientWallet.getBalance().add(amount));
        walletRepo.save(recipientWallet);

        txRepo.save(WalletTransaction.builder()
                .username(actualRecipientUsername)
                .type(TransactionType.INGRESO)
                .amount(amount)
                .description("Transferencia recibida de " + senderUsername)
                .createdAt(LocalDateTime.now())
                .build());

        trackWalletBalanceAchievement(actualRecipientUsername, recipientWallet.getBalance());

        return getWallet(senderUsername);
    }

    public Wallet getOrCreateWallet(String username) {
        boolean isDemoUser = username != null && ("dani12@gmail.com".equalsIgnoreCase(username) ||
                userRepo.findByEmail("dani12@gmail.com").map(User::getUsername).filter(u -> u.equalsIgnoreCase(username)).isPresent());
        BigDecimal initialBalance = isDemoUser ? BigDecimal.valueOf(5000.00) : BigDecimal.valueOf(100.00);

        return walletRepo.findByUsername(username)
                .map(w -> {
                    if (isDemoUser && w.getBalance().compareTo(BigDecimal.valueOf(1000.00)) < 0) {
                        w.setBalance(BigDecimal.valueOf(5000.00));
                        return walletRepo.save(w);
                    }
                    return w;
                })
                .orElseGet(() -> walletRepo.save(Wallet.builder()
                        .username(username)
                        .balance(initialBalance)
                        .activePlanId("free")
                        .nextBillingDate(LocalDateTime.now().plusDays(30))
                        .build()));
    }

    private BigDecimal calculatePlanCost(String planId, String cycle) {
        boolean isAnnual = "annual".equalsIgnoreCase(cycle);
        return switch (planId.toLowerCase()) {
            case "pro" -> isAnnual ? BigDecimal.valueOf(2000.00) : BigDecimal.valueOf(200.00);
            case "vip" -> isAnnual ? BigDecimal.valueOf(5000.00) : BigDecimal.valueOf(500.00);
            default -> BigDecimal.ZERO;
        };
    }
}
