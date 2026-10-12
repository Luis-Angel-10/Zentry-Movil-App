# Skill: Agregar Campos a una Entidad Existente

## Descripción
Cuando necesites agregar uno o más campos nuevos a una entidad existente, debes modificar TODOS los archivos del stack (Model, DTOs, Service, Mapper). Esta skill te guía en el proceso.

## Archivos a Modificar (en orden)

### 1. Model — Agregar el campo
Ubicación: `src/main/java/zentry/back/api/{modulo}/models/{Entidad}.java`
```java
// Agregar el campo con su @Column
@Column(name = "nuevo_campo", length = 255)
private String nuevoCampo;
```

### 2. Request DTO — Agregar con validaciones
Ubicación: `src/main/java/zentry/back/api/{modulo}/dtos/{Entidad}Request.java`
```java
@NotBlank
@Size(max = 255)
private String nuevoCampo;
```

### 3. Response DTO — Agregar sin validaciones
Ubicación: `src/main/java/zentry/back/api/{modulo}/dtos/{Entidad}Response.java`
```java
private String nuevoCampo;
```

### 4. Mapper — Agregar al builder del toResponse
Ubicación: `src/main/java/zentry/back/api/global/mappers.java`
```java
public static {Entidad}Response toResponse({Entidad} entity) {
    if (entity == null) return null;
    return {Entidad}Response.builder()
            .id(entity.getId())
            .campoExistente(entity.getCampoExistente())
            .nuevoCampo(entity.getNuevoCampo())  // ← AGREGAR
            .build();
}
```

### 5. Service — Agregar al create y update
Ubicación: `src/main/java/zentry/back/api/{modulo}/services/{Entidad}Service.java`

**En create():**
```java
{Entidad} entity = {Entidad}.builder()
        .campoExistente(request.getCampoExistente())
        .nuevoCampo(request.getNuevoCampo())  // ← AGREGAR
        .build();
```

**En update():**
```java
entity.setCampoExistente(request.getCampoExistente());
entity.setNuevoCampo(request.getNuevoCampo());  // ← AGREGAR
```

### 6. Tests — Actualizar sample() y requests
Ubicación: `src/test/java/zentry/back/api/{modulo}/{Entidad}ControllerTest.java`

## Checklist
- [ ] Model: campo con @Column
- [ ] Request DTO: campo con validaciones
- [ ] Response DTO: campo sin validaciones
- [ ] Mapper: campo en el builder de toResponse
- [ ] Service create(): campo en el builder
- [ ] Service update(): setter del campo
- [ ] Tests: actualizar sample() y request builders

## Tipos de Campos Comunes

| Tipo Java | Tipo DB | Anotación @Column |
|-----------|---------|-------------------|
| `String` | VARCHAR | `@Column(length = 100)` |
| `String` | TEXT | `@Column(columnDefinition = "TEXT")` |
| `Integer` | INTEGER | `@Column` |
| `Boolean` | BOOLEAN | `@Column` |
| `Double` | DOUBLE | `@Column` |
| `BigDecimal` | NUMERIC | `@Column(precision = 10, scale = 2)` |
| `LocalDateTime` | TIMESTAMP | `@Column` |
| `LocalDate` | DATE | `@Column` |

## Reglas
- NO usar `@ManyToOne` — usar Integer FK: `private Integer referenciaId;`
- Campos de auditoría van al final: `createdAt`, `updatedAt`
- Los campos sensibles (password, tokens) NUNCA van en el Response DTO
- Si el campo es un FK, nombrarlo como `{entidadReferenciada}Id` (ej: `userId`, `postId`)
