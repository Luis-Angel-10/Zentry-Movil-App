package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zentry.back.api.core.dtos.TrendingTopicResponse;
import zentry.back.api.core.dtos.UnifiedSearchResponse;
import zentry.back.api.core.services.ExploreService;

import java.util.List;

@RestController
@RequestMapping({"/api/core", "/api/v1"})
@Tag(name = "Explorar y Búsqueda", description = "Endpoints de tendencias estilo X y búsqueda unificada multimodal")
public class ExploreController {

    private final ExploreService exploreService;

    public ExploreController(ExploreService exploreService) {
        this.exploreService = exploreService;
    }

    // ─── GET /api/core/explore/trending ───────────────────────────────────────
    @Operation(summary = "Obtener tendencias actuales estilo X",
               description = "Devuelve una lista de hashtags y categorías en tendencia ordenados por cantidad de publicaciones.")
    @GetMapping("/explore/trending")
    public ResponseEntity<List<TrendingTopicResponse>> getTrending() {
        return ResponseEntity.ok(exploreService.getTrendingTopics());
    }

    // ─── GET /api/core/explore/history ────────────────────────────────────────
    @Operation(summary = "Obtener archivo histórico de tendencias",
               description = "Devuelve el resumen de las mejores tendencias ordenadas por año.")
    @GetMapping("/explore/history")
    public ResponseEntity<List<TrendingTopicResponse>> getHistory(
            @Parameter(description = "Año a consultar (ej: 2026, 2025)") @RequestParam(required = false) Integer year) {
        return ResponseEntity.ok(exploreService.getTrendingHistory(year));
    }

    // ─── GET /api/core/search ──────────────────────────────────────────────────
    @Operation(summary = "Búsqueda multimodal unificada",
               description = "Ejecuta una búsqueda combinada de usuarios, obras/posts y hashtags en tendencia dada una palabra clave.")
    @GetMapping("/search")
    public ResponseEntity<UnifiedSearchResponse> search(
            @Parameter(description = "Término o palabra clave de búsqueda") @RequestParam(required = false, defaultValue = "") String query) {
        return ResponseEntity.ok(exploreService.unifiedSearch(query));
    }
}
