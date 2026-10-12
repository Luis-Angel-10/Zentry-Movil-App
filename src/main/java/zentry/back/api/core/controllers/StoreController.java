package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import zentry.back.api.core.dtos.StoreItemResponse;
import zentry.back.api.core.dtos.StorePurchaseResponse;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.core.services.StoreService;

import java.security.Principal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping({"/api/core/store", "/api/v1/store"})
@Tag(name = "Tienda", description = "Endpoints para ver y comprar artículos de la tienda con Zentry Coins")
public class StoreController {

    private final StoreService storeService;
    private final UserRepository userRepository;

    public StoreController(StoreService storeService, UserRepository userRepository) {
        this.storeService = storeService;
        this.userRepository = userRepository;
    }

    @GetMapping("/items")
    @Operation(summary = "Listar todos los artículos de la tienda",
               description = "Devuelve el catálogo de la tienda indicando cuáles ya posee el usuario autenticado.")
    public ResponseEntity<List<StoreItemResponse>> getStoreItems(Principal principal, Authentication authentication) {
        User user = resolveUser(extractUsername(principal, authentication));
        return ResponseEntity.ok(storeService.getAllItems(user.getId()));
    }

    @GetMapping("/purchases")
    @Operation(summary = "Listar mis compras", description = "Devuelve los artículos comprados por el usuario autenticado.")
    public ResponseEntity<List<StorePurchaseResponse>> getMyPurchases(Principal principal, Authentication authentication) {
        User user = resolveUser(extractUsername(principal, authentication));
        return ResponseEntity.ok(storeService.getPurchasesForUser(user.getId()));
    }

    @PostMapping("/buy/{itemId}")
    @Operation(summary = "Comprar un artículo con Zentry Coins")
    public ResponseEntity<StorePurchaseResponse> buyItem(
            @PathVariable Integer itemId,
            Principal principal,
            Authentication authentication) {

        String username = extractUsername(principal, authentication);
        return ResponseEntity.ok(storeService.buyItem(username, itemId));
    }

    @GetMapping("/equipped")
    @Operation(summary = "Ver mis ítems equipados", description = "Devuelve el ítem equipado por categoría (frames/pets/banners/themes/titles).")
    public ResponseEntity<Map<String, Integer>> getEquippedItems(Principal principal, Authentication authentication) {
        User user = resolveUser(extractUsername(principal, authentication));
        return ResponseEntity.ok(storeService.getEquippedItems(user.getId()));
    }

    @PostMapping("/equip/{itemId}")
    @Operation(summary = "Equipar o desequipar un artículo",
               description = "Requiere haberlo comprado. Si ya estaba equipado, lo desequipa; si no, reemplaza lo equipado en su categoría.")
    public ResponseEntity<Map<String, Integer>> toggleEquip(
            @PathVariable Integer itemId,
            Principal principal,
            Authentication authentication) {
        User user = resolveUser(extractUsername(principal, authentication));
        return ResponseEntity.ok(storeService.toggleEquip(user.getId(), itemId));
    }

    private String extractUsername(Principal principal, Authentication authentication) {
        if (principal != null) {
            return principal.getName();
        }
        if (authentication != null) {
            return authentication.getName();
        }
        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Debes iniciar sesión");
    }

    private User resolveUser(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no encontrado"));
    }
}
