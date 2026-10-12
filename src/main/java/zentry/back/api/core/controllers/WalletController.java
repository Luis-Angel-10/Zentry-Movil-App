package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import zentry.back.api.core.dtos.*;
import zentry.back.api.core.services.WalletService;

import java.security.Principal;

@RestController
@RequestMapping({"/api/core/wallet", "/api/v1/wallet"})
@Tag(name = "Billetera y Suscripciones", description = "CRUD de Zentry Coins, suscripciones a planes (Pro, VIP) y transferencias entre creadores")
public class WalletController {

    private final WalletService walletService;

    public WalletController(WalletService walletService) {
        this.walletService = walletService;
    }

    // ─── GET /api/core/wallet ──────────────────────────────────────────────────
    @Operation(summary = "Obtener estado de billetera y suscripción",
               description = "Retorna el saldo de Zentry Coins, plan activo, fecha de renovación e historial de transacciones.")
    @GetMapping
    public ResponseEntity<WalletResponse> getWallet(Principal principal, Authentication authentication) {
        String username = extractUsername(principal, authentication);
        return ResponseEntity.ok(walletService.getWallet(username));
    }

    // ─── POST /api/core/wallet/subscribe ──────────────────────────────────────
    @Operation(summary = "Cambiar o suscribirse a un plan",
               description = "Valida saldo suficiente en Zentry Coins, descuenta el importe, actualiza el plan activo y registra la transacción de egreso.")
    @PostMapping("/subscribe")
    public ResponseEntity<WalletResponse> subscribe(Principal principal, Authentication authentication,
                                                    @Valid @RequestBody SubscribeRequest request) {
        String username = extractUsername(principal, authentication);
        return ResponseEntity.ok(walletService.subscribe(username, request));
    }

    // ─── POST /api/core/wallet/topup ──────────────────────────────────────────
    @Operation(summary = "Recargar Zentry Coins (ZC)",
               description = "Incrementa el saldo de ZC de la billetera del usuario y registra la transacción de recarga.")
    @PostMapping({"/topup", "/recharge"})
    public ResponseEntity<WalletResponse> topup(Principal principal, Authentication authentication,
                                                @Valid @RequestBody TopupRequest request) {
        String username = extractUsername(principal, authentication);
        return ResponseEntity.ok(walletService.topup(username, request));
    }

    // ─── POST /api/core/wallet/transfer ───────────────────────────────────────
    @Operation(summary = "Transferir ZC a otro creador",
               description = "Realiza una transferencia atómica de Zentry Coins descontando del emisor e incrementando en la billetera del receptor.")
    @PostMapping("/transfer")
    public ResponseEntity<WalletResponse> transfer(Principal principal, Authentication authentication,
                                                   @Valid @RequestBody TransferRequest request) {
        String username = extractUsername(principal, authentication);
        return ResponseEntity.ok(walletService.transfer(username, request));
    }

    private String extractUsername(Principal principal, Authentication authentication) {
        if (principal != null) {
            return principal.getName();
        }
        if (authentication != null) {
            return authentication.getName();
        }
        return "admin@zentry.com";
    }
}
