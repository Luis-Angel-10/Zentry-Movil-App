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
import zentry.back.api.business.controllers.OrderItemsController;
import zentry.back.api.business.dtos.OrderItemsRequest;
import zentry.back.api.business.dtos.OrderItemsResponse;
import zentry.back.api.business.services.OrderItemsService;

import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Import({SecurityConfig.class, TestSecurityBeansConfig.class})
@WebMvcTest(OrderItemsController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("OrderItemsController")
@SuppressWarnings("all")
class OrderItemsControllerTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @MockitoBean  OrderItemsService service;

    private static final String BASE = "/api/business/order-items";
    private static final UUID orderUuid = UUID.randomUUID();
    private static final UUID productUuid = UUID.randomUUID();

    private OrderItemsResponse sample() {
        return OrderItemsResponse.builder().orderId(orderUuid).productId(productUuid).cantidad(5).build();
    }

    @Nested @DisplayName("GET /") @SuppressWarnings("all")
class ListTests {
        @Test void list_200() throws Exception {
            when(service.list(any(Pageable.class))).thenReturn(new PageImpl<>(List.of(sample())));
            mvc.perform(get(BASE)).andExpect(status().isOk())
               .andExpect(jsonPath("$.content[0].orderId").value(orderUuid.toString()));
        }
    }

    @Nested @DisplayName("GET /{orderId}/{productId}") @SuppressWarnings("all")
class GetByIdTests {
        @Test void getById_200() throws Exception {
            when(service.getById(orderUuid, productUuid)).thenReturn(sample());
            mvc.perform(get(BASE + "/" + orderUuid + "/" + productUuid)).andExpect(status().isOk())
               .andExpect(jsonPath("$.cantidad").value(5));
        }
        @Test void getById_404() throws Exception {
            when(service.getById(any(), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(get(BASE + "/" + UUID.randomUUID() + "/" + UUID.randomUUID())).andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("POST /") @SuppressWarnings("all")
class CreateTests {
        @Test void create_201() throws Exception {
            OrderItemsRequest req = OrderItemsRequest.builder().orderId(orderUuid).productId(productUuid).cantidad(5).build();
            when(service.create(any())).thenReturn(sample());
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isCreated()).andExpect(jsonPath("$.orderId").value(orderUuid.toString()));
        }
        @Test void create_400_duplicate() throws Exception {
            when(service.create(any())).thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST));
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON)
               .content(json.writeValueAsString(OrderItemsRequest.builder().orderId(orderUuid).productId(productUuid).cantidad(1).build())))
               .andExpect(status().isBadRequest());
        }
    }

    @Nested @DisplayName("PUT /{orderId}/{productId}") @SuppressWarnings("all")
class UpdateTests {
        @Test void update_200() throws Exception {
            OrderItemsRequest req = OrderItemsRequest.builder().orderId(orderUuid).productId(productUuid).cantidad(99).build();
            when(service.update(eq(orderUuid), eq(productUuid), any()))
                .thenReturn(OrderItemsResponse.builder().orderId(orderUuid).productId(productUuid).cantidad(99).build());
            mvc.perform(put(BASE + "/" + orderUuid + "/" + productUuid).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isOk()).andExpect(jsonPath("$.cantidad").value(99));
        }
        @Test void update_404() throws Exception {
            when(service.update(any(), any(), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(put(BASE + "/" + UUID.randomUUID() + "/" + UUID.randomUUID()).contentType(MediaType.APPLICATION_JSON)
               .content(json.writeValueAsString(OrderItemsRequest.builder().orderId(UUID.randomUUID()).productId(UUID.randomUUID()).cantidad(1).build())))
               .andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("DELETE /{orderId}/{productId}") @SuppressWarnings("all")
class DeleteTests {
        @Test void delete_204() throws Exception {
            doNothing().when(service).delete(orderUuid, productUuid);
            mvc.perform(delete(BASE + "/" + orderUuid + "/" + productUuid)).andExpect(status().isNoContent());
        }
        @Test void delete_404() throws Exception {
            doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND)).when(service).delete(any(), any());
            mvc.perform(delete(BASE + "/" + UUID.randomUUID() + "/" + UUID.randomUUID())).andExpect(status().isNotFound());
        }
    }
}
