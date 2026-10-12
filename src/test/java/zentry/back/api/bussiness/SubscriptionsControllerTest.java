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
import zentry.back.api.business.controllers.SubscriptionsController;
import zentry.back.api.business.dtos.SubscriptionsRequest;
import zentry.back.api.business.dtos.SubscriptionsResponse;
import zentry.back.api.business.services.SubscriptionsService;

import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Import({SecurityConfig.class, TestSecurityBeansConfig.class})
@WebMvcTest(SubscriptionsController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("SubscriptionsController")
@SuppressWarnings("all")
class SubscriptionsControllerTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @MockitoBean  SubscriptionsService service;

    private static final String BASE = "/api/business/subscriptions";
    private final UUID id = UUID.randomUUID();
    private final UUID planId = UUID.randomUUID();

    private SubscriptionsResponse sample() {
        return SubscriptionsResponse.builder().id(id).userId(1).planId(planId).build();
    }

    @Nested @DisplayName("GET /") @SuppressWarnings("all")
class ListTests {
        @Test void list_200() throws Exception {
            when(service.list(any(Pageable.class))).thenReturn(new PageImpl<>(List.of(sample())));
            mvc.perform(get(BASE)).andExpect(status().isOk())
               .andExpect(jsonPath("$.content[0].userId").value(1));
        }
    }

    @Nested @DisplayName("GET /{id}") @SuppressWarnings("all")
class GetByIdTests {
        @Test void getById_200() throws Exception {
            when(service.getById(id)).thenReturn(sample());
            mvc.perform(get(BASE + "/" + id)).andExpect(status().isOk())
               .andExpect(jsonPath("$.userId").value(1));
        }
        @Test void getById_404() throws Exception {
            UUID u = UUID.randomUUID();
            when(service.getById(u)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(get(BASE + "/" + u)).andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("POST /") @SuppressWarnings("all")
class CreateTests {
        @Test void create_201() throws Exception {
            SubscriptionsRequest req = SubscriptionsRequest.builder().userId(1).planId(planId).build();
            when(service.create(any())).thenReturn(sample());
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isCreated()).andExpect(jsonPath("$.userId").value(1));
        }
        @Test void create_400_duplicate() throws Exception {
            when(service.create(any())).thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST));
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON)
               .content(json.writeValueAsString(SubscriptionsRequest.builder().userId(1).planId(UUID.randomUUID()).build())))
               .andExpect(status().isBadRequest());
        }
    }

    @Nested @DisplayName("PUT /{id}") @SuppressWarnings("all")
class UpdateTests {
        @Test void update_200() throws Exception {
            SubscriptionsRequest req = SubscriptionsRequest.builder().userId(1).planId(UUID.randomUUID()).build();
            when(service.update(eq(id), any())).thenReturn(SubscriptionsResponse.builder().id(id).userId(1).planId(UUID.randomUUID()).build());
            mvc.perform(put(BASE + "/" + id).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isOk());
        }
        @Test void update_404() throws Exception {
            UUID u = UUID.randomUUID();
            when(service.update(eq(u), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(put(BASE + "/" + u).contentType(MediaType.APPLICATION_JSON)
               .content(json.writeValueAsString(SubscriptionsRequest.builder().userId(1).planId(planId).build())))
               .andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("DELETE /{id}") @SuppressWarnings("all")
class DeleteTests {
        @Test void delete_204() throws Exception {
            doNothing().when(service).delete(id);
            mvc.perform(delete(BASE + "/" + id)).andExpect(status().isNoContent());
        }
        @Test void delete_404() throws Exception {
            UUID u = UUID.randomUUID();
            doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND)).when(service).delete(u);
            mvc.perform(delete(BASE + "/" + u)).andExpect(status().isNotFound());
        }
    }
}
