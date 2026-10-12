package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.SubscriptionPlansRequest;
import zentry.back.api.business.dtos.SubscriptionPlansResponse;
import zentry.back.api.business.models.SubscriptionPlans;
import zentry.back.api.business.repositories.SubscriptionPlansRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class SubscriptionPlansService {

    private final SubscriptionPlansRepository repo;

    public SubscriptionPlansService(SubscriptionPlansRepository repo) {
        this.repo = repo;
    }

    @jakarta.annotation.PostConstruct
    public void seedPlans() {
        seedPlan(
            "Gratuito",
            java.math.BigDecimal.ZERO,
            "Plan básico para nuevos creadores y miembros de la comunidad",
            "Crear perfil, Publicar contenido, Explorar artistas, Unirse a comunidades, Interacción básica"
        );
        seedPlan(
            "Premium Creador",
            new java.math.BigDecimal("9.99"),
            "Para creadores en crecimiento que buscan mayor alcance y monetización",
            "Mayor alcance y visibilidad, Monetización de contenido, Más Zentry Coins, Estadísticas avanzadas, Herramientas desbloqueadas y profesionales, Colaboración con marcas y proyectos, Perfil verificado, Acceso anticipado a futuras funciones"
        );
        seedPlan(
            "Premium PRO",
            new java.math.BigDecimal("19.99"),
            "Acceso completo a la suite profesional de IA y oportunidades exclusivas",
            "Todo lo del plan Creador, Herramientas avanzadas con IA, Colaboraciones exclusivas, Acceso a eventos y concursos, Más Zentry Coins bonus, Promoción destacada de proyectos"
        );
    }

    private void seedPlan(String name, java.math.BigDecimal precio, String description, String features) {
        SubscriptionPlans plan = repo.findByName(name).orElse(null);
        if (plan == null) {
            repo.save(SubscriptionPlans.builder()
                    .name(name)
                    .precio(precio)
                    .description(description)
                    .features(features)
                    .build());
        } else {
            plan.setPrecio(precio);
            plan.setDescription(description);
            plan.setFeatures(features);
            repo.save(plan);
        }
    }

    public Page<SubscriptionPlansResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public SubscriptionPlansResponse getById(UUID id) {
        SubscriptionPlans entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SubscriptionPlan not found"));
        return BusinessMappers.toResponse(entity);
    }

    public SubscriptionPlansResponse create(SubscriptionPlansRequest request) {
        if (repo.existsByName(request.getName())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "A plan with this name already exists");
        }
        SubscriptionPlans entity = SubscriptionPlans.builder()
                .name(request.getName())
                .precio(request.getPrecio())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public SubscriptionPlansResponse update(UUID id, SubscriptionPlansRequest request) {
        SubscriptionPlans entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SubscriptionPlan not found"));
        entity.setName(request.getName());
        entity.setPrecio(request.getPrecio());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        SubscriptionPlans entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SubscriptionPlan not found"));
        repo.delete(entity);
    }
}
