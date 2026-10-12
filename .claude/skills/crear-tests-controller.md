# Skill: Crear Tests para Controladores

## Descripción
Genera tests unitarios para controladores REST siguiendo el patrón exacto del proyecto Zentry.

## Patrón Base del Proyecto

Los tests del proyecto usan:
- `@WebMvcTest` — slice test solo del controller
- `@MockBean` — mock del service
- `@Import(securityConfig.class)` — importa la config de seguridad
- `@Nested` + `@DisplayName` — organización por endpoint
- `MockMvc` para peticiones HTTP
- `ObjectMapper` para serialización JSON

## Template Completo

```java
package zentry.back.api.{modulo};

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.context.annotation.Import;

import zentry.back.api.config.securityConfig;
import zentry.back.api.{modulo}.controllers.{Entidad}Controller;
import zentry.back.api.{modulo}.dtos.{Entidad}Request;
import zentry.back.api.{modulo}.dtos.{Entidad}Response;
import zentry.back.api.{modulo}.services.{Entidad}Service;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Import(securityConfig.class)
@WebMvcTest({Entidad}Controller.class)
@DisplayName("{Entidad}Controller")
class {Entidad}ControllerTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @MockBean  {Entidad}Service service;

    private static final String BASE = "/api/{modulo}/{entidad-plural}";

    private {Entidad}Response sample() {
        return {Entidad}Response.builder()
                .id(1)
                // .otherField("value")
                .build();
    }

    @Nested @DisplayName("GET /")
    class ListTests {
        @Test @DisplayName("200 returns page")
        void list_200() throws Exception {
            when(service.list(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(sample())));
            mvc.perform(get(BASE))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.content[0].id").value(1));
        }
    }

    @Nested @DisplayName("GET /{id}")
    class GetByIdTests {
        @Test @DisplayName("200 when found")
        void getById_200() throws Exception {
            when(service.getById(1)).thenReturn(sample());
            mvc.perform(get(BASE + "/1"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.id").value(1));
        }

        @Test @DisplayName("404 when not found")
        void getById_404() throws Exception {
            when(service.getById(999))
                .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(get(BASE + "/999"))
               .andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("POST /")
    class CreateTests {
        @Test @DisplayName("201 on success")
        void create_201() throws Exception {
            {Entidad}Request req = {Entidad}Request.builder()
                    // .field("value")
                    .build();
            when(service.create(any())).thenReturn(sample());
            mvc.perform(post(BASE)
                   .contentType(MediaType.APPLICATION_JSON)
                   .content(json.writeValueAsString(req)))
               .andExpect(status().isCreated());
        }
    }

    @Nested @DisplayName("PUT /{id}")
    class UpdateTests {
        @Test @DisplayName("200 on success")
        void update_200() throws Exception {
            {Entidad}Request req = {Entidad}Request.builder()
                    // .field("updated")
                    .build();
            when(service.update(eq(1), any())).thenReturn(sample());
            mvc.perform(put(BASE + "/1")
                   .contentType(MediaType.APPLICATION_JSON)
                   .content(json.writeValueAsString(req)))
               .andExpect(status().isOk());
        }

        @Test @DisplayName("404 when not found")
        void update_404() throws Exception {
            when(service.update(eq(999), any()))
                .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(put(BASE + "/999")
                   .contentType(MediaType.APPLICATION_JSON)
                   .content(json.writeValueAsString({Entidad}Request.builder().build())))
               .andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("DELETE /{id}")
    class DeleteTests {
        @Test @DisplayName("204 on success")
        void delete_204() throws Exception {
            doNothing().when(service).delete(1);
            mvc.perform(delete(BASE + "/1"))
               .andExpect(status().isNoContent());
        }

        @Test @DisplayName("404 when not found")
        void delete_404() throws Exception {
            doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND))
                .when(service).delete(999);
            mvc.perform(delete(BASE + "/999"))
               .andExpect(status().isNotFound());
        }
    }
}
```

## Reglas
- El paquete de test para `core` es: `zentry.back.api.core`
- El paquete de test para `business` es: `zentry.back.api.bussiness` (⚠️ con doble 's' — así está en el proyecto)
- Siempre incluir `@Import(securityConfig.class)` — sin esto, los tests fallan por Spring Security
- IDs de test: usar Integer (1, 2, 999) para core/ai, UUID para business
- Test naming convention: `methodName_expectedStatusCode` (e.g., `list_200`, `getById_404`)
- Mínimo 7 tests por controller: list, getById found, getById not found, create, update, update not found, delete, delete not found
