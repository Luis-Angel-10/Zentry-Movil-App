package zentry.back.api.core.repositories;

import zentry.back.api.core.models.Community;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface CommunityRepository extends JpaRepository<Community, Integer> {
    Optional<Community> findByNombreIgnoreCase(String nombre);
    Optional<Community> findBySlug(String slug);
    boolean existsBySlug(String slug);

    // NOTA: puede haber más de una coincidencia si existen datos duplicados
    // (p.ej. de siembras antiguas). Usar findAllBySlugOrNombreMatch en vez de
    // esta versión ".orElse/.orElseThrow" cuando no se pueda garantizar unicidad,
    // ya que lanza NonUniqueResultException si hay más de un resultado.
    @Query("SELECT c FROM Community c WHERE c.slug = :slug OR LOWER(REPLACE(REPLACE(c.nombre, ' ', '-'), '/', '-')) = LOWER(:slug) OR LOWER(c.nombre) = LOWER(:slug)")
    Optional<Community> findBySlugOrNombre(@Param("slug") String slug);

    @Query("SELECT c FROM Community c WHERE c.slug = :slug OR LOWER(REPLACE(REPLACE(c.nombre, ' ', '-'), '/', '-')) = LOWER(:slug) OR LOWER(c.nombre) = LOWER(:slug)")
    List<Community> findAllBySlugOrNombreMatch(@Param("slug") String slug);

    @Query("SELECT c FROM Community c WHERE LOWER(c.nombre) LIKE LOWER(CONCAT('%', :search, '%')) OR LOWER(c.slug) LIKE LOWER(CONCAT('%', :search, '%')) OR LOWER(c.descripcion) LIKE LOWER(CONCAT('%', :search, '%')) OR LOWER(c.categoria) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<Community> findSearch(@Param("search") String search, Pageable pageable);
}