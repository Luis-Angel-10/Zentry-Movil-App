package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.AdsCampaignsRequest;
import zentry.back.api.business.dtos.AdsCampaignsResponse;
import zentry.back.api.business.models.AdImpressions;
import zentry.back.api.business.models.AdsCampaigns;
import zentry.back.api.business.repositories.AdImpressionsRepository;
import zentry.back.api.business.repositories.AdsCampaignsRepository;
import zentry.back.api.business.mappers.BusinessMappers;
import zentry.back.api.core.repositories.UserRepository;

import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@SuppressWarnings("null")
public class AdsCampaignsService {

    private final AdsCampaignsRepository repo;
    private final AdImpressionsRepository impressionsRepo;
    private final UserRepository userRepo;

    public AdsCampaignsService(AdsCampaignsRepository repo, AdImpressionsRepository impressionsRepo, UserRepository userRepo) {
        this.repo = repo;
        this.impressionsRepo = impressionsRepo;
        this.userRepo = userRepo;
    }

    /**
     * Anuncios propios de Zentry (promoción de funciones reales: Tienda, Estudio, Proyectos)
     * para que el feed y la barra lateral nunca queden vacíos mientras no haya anunciantes externos.
     * Se llama explícitamente desde DataSeeder (después de crear el usuario admin), no vía
     * @PostConstruct, para evitar una carrera de inicialización — ver el comentario en DataSeeder.
     */
    public void seedHouseAds() {
        Integer systemUserId = userRepo.findByEmail("admin@zentry.com").map(u -> u.getId()).orElse(null);
        if (systemUserId == null) return;

        Set<String> existingNames = repo.findByUserId(systemUserId).stream()
                .map(AdsCampaigns::getNombre)
                .collect(Collectors.toSet());

        List<AdsCampaigns> houseAds = List.of(
            houseAd(systemUserId, "house_shop", "Zentry Shop", "Personaliza tu perfil con marcos, mascotas y temas exclusivos.", "🛍️", "/shop", "Ver Tienda", "BOTH"),
            houseAd(systemUserId, "house_studio", "Estudio Creativo", "Crea Pixel Art, documentos, imágenes, video y audio en un solo lugar.", "🎨", "/studio", "Abrir Estudio", "BOTH"),
            houseAd(systemUserId, "house_projects", "Proyectos Colaborativos", "Invita colaboradores y organiza tareas en tus proyectos.", "📋", "/projects", "Ver Proyectos", "FEED"),
            houseAd(systemUserId, "house_communities", "Comunidades Zentry", "Únete a una comunidad y abre tu primer hilo de discusión.", "🏛️", "/communities", "Explorar", "SIDEBAR")
        );

        houseAds.stream()
                .filter(ad -> !existingNames.contains(ad.getNombre()))
                .forEach(repo::save);
    }

    private static AdsCampaigns houseAd(Integer userId, String nombre, String headline, String body,
                                         String imageUrl, String linkUrl, String ctaLabel, String placement) {
        return AdsCampaigns.builder()
                .userId(userId)
                .nombre(nombre)
                .headline(headline)
                .body(body)
                .imageUrl(imageUrl)
                .linkUrl(linkUrl)
                .ctaLabel(ctaLabel)
                .placement(placement)
                .isActive(true)
                .build();
    }

    public Page<AdsCampaignsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public AdsCampaignsResponse getById(UUID id) {
        AdsCampaigns entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AdsCampaign not found"));
        return BusinessMappers.toResponse(entity);
    }

    /**
     * Anuncios activos para un lugar concreto del front (FEED o SIDEBAR).
     * BOTH se incluye siempre. El orden se mezcla para rotar cuál se muestra primero.
     */
    public List<AdsCampaignsResponse> getActiveAds(String placement) {
        String normalized = placement != null ? placement.toUpperCase() : "BOTH";
        List<String> placements = "BOTH".equals(normalized)
                ? List.of("BOTH")
                : Arrays.asList(normalized, "BOTH");

        List<AdsCampaigns> ads = repo.findByIsActiveTrueAndPlacementIn(placements);
        java.util.Collections.shuffle(ads);
        return ads.stream().map(BusinessMappers::toResponse).collect(Collectors.toList());
    }

    public void recordImpression(UUID campaignId) {
        if (!repo.existsById(campaignId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "AdsCampaign not found");
        }
        AdImpressions impression = impressionsRepo.findByCampaignId(campaignId).stream()
                .findFirst()
                .orElseGet(() -> AdImpressions.builder().campaignId(campaignId).vistas(0).build());
        impression.setVistas((impression.getVistas() != null ? impression.getVistas() : 0) + 1);
        impressionsRepo.save(impression);
    }

    public AdsCampaignsResponse create(AdsCampaignsRequest request) {
        if (repo.existsByUserIdAndNombre(request.getUserId(), request.getNombre())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "User already has a campaign with this name");
        }
        AdsCampaigns entity = AdsCampaigns.builder()
                .userId(request.getUserId())
                .nombre(request.getNombre())
                .headline(request.getHeadline())
                .body(request.getBody())
                .imageUrl(request.getImageUrl())
                .linkUrl(request.getLinkUrl())
                .ctaLabel(request.getCtaLabel())
                .placement(request.getPlacement() != null ? request.getPlacement() : "BOTH")
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public AdsCampaignsResponse update(UUID id, AdsCampaignsRequest request) {
        AdsCampaigns entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AdsCampaign not found"));
        entity.setUserId(request.getUserId());
        entity.setNombre(request.getNombre());
        if (request.getHeadline() != null) entity.setHeadline(request.getHeadline());
        if (request.getBody() != null) entity.setBody(request.getBody());
        if (request.getImageUrl() != null) entity.setImageUrl(request.getImageUrl());
        if (request.getLinkUrl() != null) entity.setLinkUrl(request.getLinkUrl());
        if (request.getCtaLabel() != null) entity.setCtaLabel(request.getCtaLabel());
        if (request.getPlacement() != null) entity.setPlacement(request.getPlacement());
        if (request.getIsActive() != null) entity.setIsActive(request.getIsActive());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        AdsCampaigns entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AdsCampaign not found"));
        repo.delete(entity);
    }
}
