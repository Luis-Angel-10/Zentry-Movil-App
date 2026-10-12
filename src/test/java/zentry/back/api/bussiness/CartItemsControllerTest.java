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
import zentry.back.api.business.controllers.CartItemsController;
import zentry.back.api.business.dtos.CartItemsRequest;
import zentry.back.api.business.dtos.CartItemsResponse;
import zentry.back.api.business.services.CartItemsService;

import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Import({SecurityConfig.class, TestSecurityBeansConfig.class})
@WebMvcTest(CartItemsController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("CartItemsController")
@SuppressWarnings("all")
class CartItemsControllerTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @MockitoBean  CartItemsService service;

    private static final String BASE = "/api/business/cart-items";
    private static final UUID cartUuid = UUID.randomUUID();
    private static final UUID productUuid = UUID.randomUUID();

    private CartItemsResponse sample() {
        return CartItemsResponse.builder().cartId(cartUuid).productId(productUuid).cantidad(3).build();
    }

    @Nested @DisplayName("GET /")
    @SuppressWarnings("all")
class ListTests {
        @Test @DisplayName("200 returns page")
        void list_200() throws Exception {
            when(service.list(any(Pageable.class))).thenReturn(new PageImpl<>(List.of(sample())));
            mvc.perform(get(BASE)).andExpect(status().isOk())
               .andExpect(jsonPath("$.content[0].cartId").value(cartUuid.toString()));
        }
    }

    @Nested @DisplayName("GET /{cartId}/{productId}")
    @SuppressWarnings("all")
class GetByIdTests {
        @Test @DisplayName("200 when found")
        void getById_200() throws Exception {
            when(service.getById(cartUuid, productUuid)).thenReturn(sample());
            mvc.perform(get(BASE + "/" + cartUuid + "/" + productUuid)).andExpect(status().isOk())
               .andExpect(jsonPath("$.cantidad").value(3));
        }

        @Test @DisplayName("404 when not found")
        void getById_404() throws Exception {
            when(service.getById(any(), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(get(BASE + "/" + UUID.randomUUID() + "/" + UUID.randomUUID())).andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("POST /")
    @SuppressWarnings("all")
class CreateTests {
        @Test @DisplayName("201 on success")
        void create_201() throws Exception {
            CartItemsRequest req = CartItemsRequest.builder().cartId(cartUuid).productId(productUuid).cantidad(3).build();
            when(service.create(any())).thenReturn(sample());
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isCreated()).andExpect(jsonPath("$.cartId").value(cartUuid.toString()));
        }

        @Test @DisplayName("400 when duplicate item")
        void create_400() throws Exception {
            CartItemsRequest req = CartItemsRequest.builder().cartId(cartUuid).productId(productUuid).cantidad(1).build();
            when(service.create(any())).thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST));
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isBadRequest());
        }
    }

    @Nested @DisplayName("PUT /{cartId}/{productId}")
    @SuppressWarnings("all")
class UpdateTests {
        @Test @DisplayName("200 on success")
        void update_200() throws Exception {
            CartItemsRequest req = CartItemsRequest.builder().cartId(cartUuid).productId(productUuid).cantidad(10).build();
            when(service.update(eq(cartUuid), eq(productUuid), any()))
                .thenReturn(CartItemsResponse.builder().cartId(cartUuid).productId(productUuid).cantidad(10).build());
            mvc.perform(put(BASE + "/" + cartUuid + "/" + productUuid).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isOk()).andExpect(jsonPath("$.cantidad").value(10));
        }

        @Test @DisplayName("404 when not found")
        void update_404() throws Exception {
            when(service.update(any(), any(), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(put(BASE + "/" + UUID.randomUUID() + "/" + UUID.randomUUID()).contentType(MediaType.APPLICATION_JSON)
               .content(json.writeValueAsString(CartItemsRequest.builder().cartId(UUID.randomUUID()).productId(UUID.randomUUID()).cantidad(1).build())))
               .andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("DELETE /{cartId}/{productId}")
    @SuppressWarnings("all")
class DeleteTests {
        @Test @DisplayName("204 on success")
        void delete_204() throws Exception {
            doNothing().when(service).delete(cartUuid, productUuid);
            mvc.perform(delete(BASE + "/" + cartUuid + "/" + productUuid)).andExpect(status().isNoContent());
        }

        @Test @DisplayName("404 when not found")
        void delete_404() throws Exception {
            doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND)).when(service).delete(any(), any());
            mvc.perform(delete(BASE + "/" + UUID.randomUUID() + "/" + UUID.randomUUID())).andExpect(status().isNotFound());
        }
    }
}
