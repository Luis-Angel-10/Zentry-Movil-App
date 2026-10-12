package zentry.back.api.bussiness;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.config.SecurityConfig;
import zentry.back.api.business.controllers.MarketplaceOrdersController;
import zentry.back.api.business.dtos.*;
import zentry.back.api.business.services.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Import({SecurityConfig.class, TestSecurityBeansConfig.class})
@WebMvcTest(MarketplaceOrdersController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("MarketplaceOrdersController")
@SuppressWarnings("all")
class MarketplaceOrdersControllerTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @MockitoBean  MarketplaceOrdersService service;

    private static final String BASE = "/api/business/marketplace-orders";
    private final UUID id = UUID.randomUUID();

    private MarketplaceOrdersResponse sample() {
        return MarketplaceOrdersResponse.builder().id(id).buyerId(1).total(new BigDecimal("120.00")).build();
    }

    @Nested @DisplayName("GET /") @SuppressWarnings("all")
class List200 {
        @Test void ok() throws Exception {
            when(service.list(any(Pageable.class))).thenReturn(new PageImpl<>(List.of(sample())));
            mvc.perform(get(BASE)).andExpect(status().isOk())
               .andExpect(jsonPath("$.content[0].buyerId").value(1));
        }
    }

    @Nested @DisplayName("GET /{id}") @SuppressWarnings("all")
class GetById {
        @Test void found() throws Exception {
            when(service.getById(id)).thenReturn(sample());
            mvc.perform(get(BASE + "/" + id)).andExpect(status().isOk())
               .andExpect(jsonPath("$.total").value(120.00));
        }
        @Test void notFound() throws Exception {
            UUID u = UUID.randomUUID();
            when(service.getById(u)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(get(BASE + "/" + u)).andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("POST /") @SuppressWarnings("all")
class Create {
        @Test void created() throws Exception {
            MarketplaceOrdersRequest req = MarketplaceOrdersRequest.builder().buyerId(1).total(new BigDecimal("120.00")).build();
            when(service.create(any())).thenReturn(sample());
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isCreated());
        }
    }

    @Nested @DisplayName("PUT /{id}") @SuppressWarnings("all")
class Update {
        @Test void updated() throws Exception {
            MarketplaceOrdersRequest req = MarketplaceOrdersRequest.builder().buyerId(2).total(new BigDecimal("200.00")).build();
            when(service.update(eq(id), any())).thenReturn(MarketplaceOrdersResponse.builder().id(id).buyerId(2).total(new BigDecimal("200.00")).build());
            mvc.perform(put(BASE + "/" + id).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isOk()).andExpect(jsonPath("$.buyerId").value(2));
        }
        @Test void notFound() throws Exception {
            UUID u = UUID.randomUUID();
            when(service.update(eq(u), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(put(BASE + "/" + u).contentType(MediaType.APPLICATION_JSON)
               .content(json.writeValueAsString(MarketplaceOrdersRequest.builder().buyerId(1).total(BigDecimal.TEN).build())))
               .andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("DELETE /{id}") @SuppressWarnings("all")
class Delete {
        @Test void deleted() throws Exception {
            doNothing().when(service).delete(id);
            mvc.perform(delete(BASE + "/" + id)).andExpect(status().isNoContent());
        }
        @Test void notFound() throws Exception {
            UUID u = UUID.randomUUID();
            doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND)).when(service).delete(u);
            mvc.perform(delete(BASE + "/" + u)).andExpect(status().isNotFound());
        }
    }
}
