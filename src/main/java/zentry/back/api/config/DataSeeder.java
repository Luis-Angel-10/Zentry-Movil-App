package zentry.back.api.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import zentry.back.api.core.models.Community;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.CommunityMemberRepository;
import zentry.back.api.core.repositories.CommunityRepository;
import zentry.back.api.core.repositories.ForumReplyRepository;
import zentry.back.api.core.repositories.ForumThreadRepository;
import zentry.back.api.core.repositories.PostRepository;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.business.services.AdsCampaignsService;

import java.util.List;

/**
 * Siembra de datos de conveniencia (usuario admin de prueba, comunidad "Zentry",
 * limpieza de comunidades de muestra antiguas, anuncios "house").
 *
 * <p>Restringido al perfil "dev": nunca se ejecuta en "prod" ni en "test", por lo
 * que no se crean credenciales por defecto (admin@zentry.com / admin123) fuera de
 * desarrollo local.
 */
@Configuration
@Profile("dev")
public class DataSeeder {

    // Comunidades de muestra que se sembraron en sesiones anteriores y ya no queremos:
    // se eliminan (junto con sus miembros/hilos/posts huérfanos) en cada arranque.
    private static final List<String> RETIRED_SAMPLE_SLUGS = List.of(
            "eterna", "ui-ux-designers", "digital-art", "zentry-network", "zentry-creators"
    );

    // Cuentas de prueba cuyas publicaciones de relleno ("Lienzo Art", "aaaa", etc.)
    // seguían apareciendo en el feed principal: se borran sus posts en cada arranque.
    private static final List<String> RETIRED_TEST_POST_AUTHORS = List.of("usuario");

    @Bean
    CommandLineRunner initDatabase(CommunityRepository communityRepo, UserRepository userRepo, PasswordEncoder passwordEncoder,
                                    CommunityMemberRepository communityMemberRepo, ForumThreadRepository forumThreadRepo,
                                    ForumReplyRepository forumReplyRepo, PostRepository postRepo,
                                    AdsCampaignsService adsCampaignsService) {
        return args -> {
            User admin = userRepo.findByEmail("admin@zentry.com").orElse(null);
            // Comentado a petición: no crear más usuarios de prueba
            /*
            if (admin == null) {
                admin = User.builder()
                        .username("admin")
                        .email("admin@zentry.com")
                        .password(passwordEncoder.encode("admin123"))
                        .verified(true)
                        .build();
                admin = userRepo.save(admin);
                System.out.println("👤 Usuario Administrador de prueba creado: admin@zentry.com");
            }
            */

            Integer adminId = admin != null ? admin.getId() : 1;
            String adminUsername = admin != null ? admin.getHandle() : "admin";

            for (String slug : RETIRED_SAMPLE_SLUGS) {
                // Usamos la variante que devuelve una lista: puede haber más de una
                // fila duplicada de siembras anteriores, y la versión Optional lanza
                // una excepción (NonUniqueResultException) si encuentra más de una.
                for (Community community : communityRepo.findAllBySlugOrNombreMatch(slug)) {
                    Integer communityId = community.getId();
                    forumThreadRepo.findByCommunityId(communityId).forEach(thread -> {
                        forumReplyRepo.deleteByThreadId(thread.getId());
                    });
                    forumThreadRepo.deleteAll(forumThreadRepo.findByCommunityId(communityId));
                    postRepo.deleteAll(postRepo.findByCommunityId(communityId));
                    communityMemberRepo.deleteByCommunityId(communityId);
                    communityRepo.delete(community);
                    System.out.println("🧹 Comunidad de muestra eliminada: " + community.getNombre());
                }
            }

            for (String testUsername : RETIRED_TEST_POST_AUTHORS) {
                userRepo.findByUsername(testUsername).ifPresent(testUser -> {
                    List<zentry.back.api.core.models.Post> testPosts = postRepo.findByUserIdOrderByCreatedAtDesc(testUser.getId());
                    if (!testPosts.isEmpty()) {
                        postRepo.deleteAll(testPosts);
                        System.out.println("🧹 " + testPosts.size() + " publicaciones de prueba eliminadas (autor: @" + testUsername + ")");
                    }
                });
            }

            List<Community> existingZentry = communityRepo.findAllBySlugOrNombreMatch("zentry");
            if (existingZentry.size() > 1) {
                // Deja solo la primera si por algún motivo quedaron duplicados.
                for (int i = 1; i < existingZentry.size(); i++) {
                    communityRepo.delete(existingZentry.get(i));
                }
            }
            if (existingZentry.isEmpty()) {
                communityRepo.save(Community.builder()
                        .slug("zentry")
                        .nombre("Zentry")
                        .descripcion("Comunidad oficial de prueba de Zentry. Habla sobre la plataforma, comparte ideas, reporta bugs y conecta con el equipo.")
                        .categoria("Oficial")
                        .creatorId(adminId)
                        .ownerUsername(adminUsername)
                        .rules(List.of(
                                "Respeto mutuo entre todos los miembros",
                                "Comentarios y sugerencias constructivas sobre la plataforma"
                        ))
                        .build());
                System.out.println("🌱 Comunidad de prueba 'Zentry' creada.");
            }

            // Se llama aquí (no @PostConstruct en el propio servicio) porque los CommandLineRunner
            // se ejecutan después de que todos los beans terminan su inicialización: si el usuario
            // admin@zentry.com no existía aún, un @PostConstruct en AdsCampaignsService se ejecutaría
            // ANTES de que este runner lo creara arriba, y la siembra de anuncios se saltaría siempre
            // en una base de datos nueva.
            adsCampaignsService.seedHouseAds();
        };
    }
}
