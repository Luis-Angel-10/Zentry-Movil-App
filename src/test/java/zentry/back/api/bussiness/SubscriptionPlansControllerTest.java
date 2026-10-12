package zentry.back.api.bussiness;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import org.springframework.context.annotation.Import;
import zentry.back.api.config.SecurityConfig;
import zentry.back.api.business.controllers.SubscriptionPlansController;
import zentry.back.api.business.dtos.SubscriptionPlansRequest;
import zentry.back.api.business.dtos.SubscriptionPlansResponse;
import zentry.back.api.business.services.SubscriptionPlansService;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Import({SecurityConfig.class, TestSecurityBeansConfig.class})
@WebMvcTest(SubscriptionPlansController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("SubscriptionPlansController")
@SuppressWarnings("all")
class SubscriptionPlansControllerTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @MockitoBean  SubscriptionPlansService service;

    private static final String BASE = "/api/business/subscription-plans";
    private final UUID id = UUID.randomUUID();

    private SubscriptionPlansResponse sample() {
        return SubscriptionPlansResponse.builder().id(id).name("Pro").precio(new BigDecimal("9.99")).build();
    }

    @Nested @DisplayName("GET /") @SuppressWarnings("all")
class ListTests {
        @Test @DisplayName("200 page") void list_200() throws Exception {
            when(service.list(any(Pageable.class))).thenReturn(new PageImpl<>(List.of(sample())));
            mvc.perform(get(BASE)).andExpect(status().isOk())
               .andExpect(jsonPath("$.content[0].name").value("Pro"));
        }
    }

    @Nested @DisplayName("GET /{id}") @SuppressWarnings("all")
class GetByIdTests {
        @Test @DisplayName("200 when found") void getById_200() throws Exception {
            when(service.getById(id)).thenReturn(sample());
            mvc.perform(get(BASE + "/" + id)).andExpect(status().isOk())
               .andExpect(jsonPath("$.name").value("Pro"));
        }
        @Test @DisplayName("404 when not found") void getById_404() throws Exception {
            UUID u = UUID.randomUUID();
            when(service.getById(u)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(get(BASE + "/" + u)).andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("POST /") @SuppressWarnings("all")
class CreateTests {
        @Test @DisplayName("201 on success") void create_201() throws Exception {
            SubscriptionPlansRequest req = SubscriptionPlansRequest.builder().name("Pro").precio(new BigDecimal("9.99")).build();
            when(service.create(any())).thenReturn(sample());
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isCreated()).andExpect(jsonPath("$.name").value("Pro"));
        }
        @Test @DisplayName("400 duplicate name") void create_400() throws Exception {
            when(service.create(any())).thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST));
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON)
               .content(json.writeValueAsString(SubscriptionPlansRequest.builder().name("Pro").precio(BigDecimal.TEN).build())))
               .andExpect(status().isBadRequest());
        }
    }

    @Nested @DisplayName("PUT /{id}") @SuppressWarnings("all")
class UpdateTests {
        @Test @DisplayName("200 on success") void update_200() throws Exception {
            SubscriptionPlansRequest req = SubscriptionPlansRequest.builder().name("Pro+").precio(new BigDecimal("19.99")).build();
            when(service.update(eq(id), any())).thenReturn(SubscriptionPlansResponse.builder().id(id).name("Pro+").precio(new BigDecimal("19.99")).build());
            mvc.perform(put(BASE + "/" + id).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isOk()).andExpect(jsonPath("$.name").value("Pro+"));
        }
        @Test @DisplayName("404 when not found") void update_404() throws Exception {
            UUID u = UUID.randomUUID();
            when(service.update(eq(u), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(put(BASE + "/" + u).contentType(MediaType.APPLICATION_JSON)
               .content(json.writeValueAsString(SubscriptionPlansRequest.builder().name("X").precio(BigDecimal.ONE).build())))
               .andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("DELETE /{id}") @SuppressWarnings("all")
class DeleteTests {
        @Test @DisplayName("204 on success") void delete_204() throws Exception {
            doNothing().when(service).delete(id);
            mvc.perform(delete(BASE + "/" + id)).andExpect(status().isNoContent());
        }
        @Test @DisplayName("404 when not found") void delete_404() throws Exception {
            UUID u = UUID.randomUUID();
            doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND)).when(service).delete(u);
            mvc.perform(delete(BASE + "/" + u)).andExpect(status().isNotFound());
        }
    }
}
