# Skill: Crear Entidad CRUD Completa

## Descripción
Crea el stack completo para una nueva entidad en el módulo especificado: Model → Repository → DTOs → Service → Controller → Mapper → Test.

## Instrucciones

Cuando el usuario pida crear una nueva entidad, sigue estos pasos EN ORDEN:

### Paso 1: Preguntar qué módulo y campos
Antes de escribir código, confirma:
- ¿En qué módulo va? (`core`, `business`, `ai`)
- ¿Qué campos tiene? (nombre, tipo, restricciones)
- ¿Qué schema de BD? (`zentry_core`, `zentry_business`, `zentry_ia`)

### Paso 2: Crear el Model
Archivo: `src/main/java/zentry/back/api/{modulo}/models/{Entidad}.java`
```java
package zentry.back.api.{modulo}.models;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "{tabla_plural}", schema = "{schema}")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class {Entidad} {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // Campos con @Column(name = "nombre_snake_case")
}
```

### Paso 3: Crear el Repository
Archivo: `src/main/java/zentry/back/api/{modulo}/repositories/{Entidad}Repository.java`

### Paso 4: Crear los DTOs
- `{Entidad}Request.java` — con validaciones `@NotBlank`, `@Size`, `@Email`, etc.
- `{Entidad}Response.java` — sin validaciones, solo campos

### Paso 5: Agregar el Mapper
En `src/main/java/zentry/back/api/global/mappers.java`:
- Agregar `public static {Entidad}Response toResponse({Entidad} entity)`
- Ubicar en la sección `#region` correspondiente (IA, Business, Core)

### Paso 6: Crear el Service
Archivo: `src/main/java/zentry/back/api/{modulo}/services/{Entidad}Service.java`
- Métodos: `list`, `getById`, `create`, `update`, `delete`
- Constructor injection
- Usar `mappers::toResponse`

### Paso 7: Crear el Controller
Archivo: `src/main/java/zentry/back/api/{modulo}/controllers/{Entidad}Controller.java`
- URL: `/api/{modulo}/{entidad-plural-kebab-case}`
- Anotaciones Swagger completas (@Operation, @ApiResponses, @Tag)
- Paginación por defecto: 20

### Paso 8: Crear el Test
Archivo: `src/test/java/zentry/back/api/{modulo}/{Entidad}ControllerTest.java`
- Patrón: @WebMvcTest + @MockBean + Nested classes
- Tests: 200 list, 200 getById, 404 getById, 201 create, 200 update, 404 update, 204 delete, 404 delete

### Checklist Final
- [ ] Model con schema correcto
- [ ] Repository extiende JpaRepository<{Entidad}, Integer>
- [ ] Request DTO con validaciones
- [ ] Response DTO sin validaciones
- [ ] Mapper agregado a mappers.java en el #region correcto
- [ ] Service con constructor injection y ResponseStatusException
- [ ] Controller con Swagger annotations
- [ ] Test con @Import(securityConfig.class)
