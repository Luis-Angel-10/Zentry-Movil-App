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

import zentry.back.api.business.controllers.AffiliatePayoutsController;
import zentry.back.api.business.dtos.AffiliatePayoutsRequest;
import zentry.back.api.business.dtos.AffiliatePayoutsResponse;
import zentry.back.api.business.services.AffiliatePayoutsService;
import zentry.back.api.config.SecurityConfig;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Import({SecurityConfig.class, TestSecurityBeansConfig.class})
@WebMvcTest(AffiliatePayoutsController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("AffiliatePayoutsController")
@SuppressWarnings("all")
class AffiliatePayoutsControllerTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @MockitoBean  AffiliatePayoutsService service;

    private static final String BASE = "/api/business/affiliate-payouts";
    private final UUID id = UUID.randomUUID();
    private static final UUID affiliateUuid = UUID.randomUUID();

    private AffiliatePayoutsResponse sample() {
        return AffiliatePayoutsResponse.builder().id(id).affiliateId(affiliateUuid).amount(new BigDecimal("15.00")).build();
    }

    @Nested @DisplayName("GET /") @SuppressWarnings("all")
class ListTests {
        @Test void list_200() throws Exception {
            when(service.list(any(Pageable.class))).thenReturn(new PageImpl<>(List.of(sample())));
            mvc.perform(get(BASE)).andExpect(status().isOk())
               .andExpect(jsonPath("$.content[0].amount").value(15.00));
        }
    }

    @Nested @DisplayName("GET /{id}") @SuppressWarnings("all")
class GetByIdTests {
        @Test void found() throws Exception {
            when(service.getById(id)).thenReturn(sample());
            mvc.perform(get(BASE + "/" + id)).andExpect(status().isOk())
               .andExpect(jsonPath("$.amount").value(15.00));
        }
        @Test void notFound() throws Exception {
            UUID u = UUID.randomUUID();
            when(service.getById(u)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(get(BASE + "/" + u)).andExpect(status().isNotFound());
        }
    }

    @Nested @DisplayName("POST /") @SuppressWarnings("all")
class CreateTests {
        @Test void create_201() throws Exception {
            AffiliatePayoutsRequest req = AffiliatePayoutsRequest.builder().affiliateId(affiliateUuid).amount(new BigDecimal("15.00")).build();
            when(service.create(any())).thenReturn(sample());
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isCreated()).andExpect(jsonPath("$.amount").value(15.00));
        }
    }

    @Nested @DisplayName("PUT /{id}") @SuppressWarnings("all")
class UpdateTests {
        @Test void update_200() throws Exception {
            AffiliatePayoutsRequest req = AffiliatePayoutsRequest.builder().affiliateId(affiliateUuid).amount(new BigDecimal("30.00")).build();
            when(service.update(eq(id), any())).thenReturn(AffiliatePayoutsResponse.builder().id(id).affiliateId(affiliateUuid).amount(new BigDecimal("30.00")).build());
            mvc.perform(put(BASE + "/" + id).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isOk()).andExpect(jsonPath("$.amount").value(30.00));
        }
        @Test void update_404() throws Exception {
            UUID u = UUID.randomUUID();
            when(service.update(eq(u), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(put(BASE + "/" + u).contentType(MediaType.APPLICATION_JSON)
               .content(json.writeValueAsString(AffiliatePayoutsRequest.builder().affiliateId(affiliateUuid).amount(BigDecimal.TEN).build())))
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
