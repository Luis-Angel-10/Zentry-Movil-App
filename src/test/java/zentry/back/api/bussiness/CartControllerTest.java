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
import zentry.back.api.business.controllers.CartController;
import zentry.back.api.business.dtos.CartRequest;
import zentry.back.api.business.dtos.CartResponse;
import zentry.back.api.business.services.CartService;

import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Import({SecurityConfig.class, TestSecurityBeansConfig.class})
@WebMvcTest(CartController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("CartController")
@SuppressWarnings("all")
class CartControllerTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @MockitoBean  CartService service;

    private static final String BASE = "/api/business/carts";
    private final UUID id = UUID.randomUUID();

    private CartResponse sample() {
        return CartResponse.builder().id(id).userId(1).build();
    }

    @Nested @DisplayName("GET /")
    
class ListTests {
        @Test @DisplayName("200 returns page")
        void list_200() throws Exception {
            when(service.list(any(Pageable.class))).thenReturn(new PageImpl<>(List.of(sample())));
            mvc.perform(get(BASE)).andExpect(status().isOk())
               .andExpect(jsonPath("$.content[0].userId").value(1));
        }
    }

    @Nested @DisplayName("GET /{id}")
    
class GetByIdTests {
        @Test @DisplayName("200 when found")
        void getById_200() throws Exception {
            when(service.getById(id)).thenReturn(sample());
            mvc.perform(get(BASE + "/" + id)).andExpect(status().isOk())
               .andExpect(jsonPath("$.userId").value(1));
        }

        @Test @DisplayName("404 when not found")
        void getById_404() throws Exception {
            UUID unknown = UUID.randomUUID();
            when(service.getById(unknown)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(get(BASE + "/" + unknown)).andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("POST /")
    
class CreateTests {
        @Test @DisplayName("201 on success")
        void create_201() throws Exception {
            CartRequest req = CartRequest.builder().userId(1).build();
            when(service.create(any())).thenReturn(sample());
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isCreated())
               .andExpect(jsonPath("$.userId").value(1));
        }
    }

    @Nested @DisplayName("PUT /{id}")
    
class UpdateTests {
        @Test @DisplayName("200 on success")
        void update_200() throws Exception {
            CartRequest req = CartRequest.builder().userId(2).build();
            when(service.update(eq(id), any())).thenReturn(CartResponse.builder().id(id).userId(2).build());
            mvc.perform(put(BASE + "/" + id).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isOk()).andExpect(jsonPath("$.userId").value(2));
        }

        @Test @DisplayName("404 when not found")
        void update_404() throws Exception {
            UUID unknown = UUID.randomUUID();
            when(service.update(eq(unknown), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(put(BASE + "/" + unknown).contentType(MediaType.APPLICATION_JSON)
               .content(json.writeValueAsString(CartRequest.builder().userId(1).build())))
               .andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("DELETE /{id}")
    
class DeleteTests {
        @Test @DisplayName("204 on success")
        void delete_204() throws Exception {
            doNothing().when(service).delete(id);
            mvc.perform(delete(BASE + "/" + id)).andExpect(status().isNoContent());
        }

        @Test @DisplayName("404 when not found")
        void delete_404() throws Exception {
            UUID unknown = UUID.randomUUID();
            doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND)).when(service).delete(unknown);
            mvc.perform(delete(BASE + "/" + unknown)).andExpect(status().isNotFound());
        }
    }
}
