package zentry.back.api.bussiness;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import org.springframework.context.annotation.Import;
import zentry.back.api.config.SecurityConfig;
import zentry.back.api.business.controllers.WalletsController;
import zentry.back.api.business.dtos.WalletsRequest;
import zentry.back.api.business.dtos.WalletsResponse;
import zentry.back.api.business.services.WalletsService;

import java.math.BigDecimal;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Import({SecurityConfig.class, TestSecurityBeansConfig.class})
@WebMvcTest(WalletsController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("WalletsController")
@SuppressWarnings("all")
class WalletsControllerTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @MockitoBean  WalletsService service;

    private static final String BASE = "/api/business/wallets";

    private WalletsResponse sampleResponse() {
        return WalletsResponse.builder().userId(1).balance(new BigDecimal("250.00")).build();
    }

    // ── GET / ────────────────────────────────────────────────────────────────
    @Nested @DisplayName("GET /")
    @SuppressWarnings("all")
class ListTests {

        @Test @DisplayName("200 with page of wallets")
        void list_200() throws Exception {
            Page<WalletsResponse> page = new PageImpl<>(List.of(sampleResponse()));
            when(service.list(any(Pageable.class))).thenReturn(page);

            mvc.perform(get(BASE))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.content[0].userId").value(1))
               .andExpect(jsonPath("$.content[0].balance").value(250.00));
        }

        @Test @DisplayName("200 with empty page")
        void list_empty() throws Exception {
            when(service.list(any(Pageable.class))).thenReturn(Page.empty());
            mvc.perform(get(BASE)).andExpect(status().isOk())
               .andExpect(jsonPath("$.content").isEmpty());
        }
    }

    // ── GET /{userId} ────────────────────────────────────────────────────────
    @Nested @DisplayName("GET /{userId}")
    @SuppressWarnings("all")
class GetByIdTests {

        @Test @DisplayName("200 when wallet exists")
        void getById_200() throws Exception {
            when(service.getById(1)).thenReturn(sampleResponse());
            mvc.perform(get(BASE + "/1"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.userId").value(1));
        }

        @Test @DisplayName("404 when wallet not found")
        void getById_404() throws Exception {
            when(service.getById(99)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(get(BASE + "/99")).andExpect(status().isNotFound());
        }
    }

    // ── POST / ───────────────────────────────────────────────────────────────
    @Nested @DisplayName("POST /")
    @SuppressWarnings("all")
class CreateTests {

        @Test @DisplayName("201 on successful creation")
        void create_201() throws Exception {
            WalletsRequest req = WalletsRequest.builder().userId(2).balance(BigDecimal.TEN).build();
            when(service.create(any())).thenReturn(WalletsResponse.builder().userId(2).balance(BigDecimal.TEN).build());

            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isCreated())
               .andExpect(jsonPath("$.userId").value(2));
        }

        @Test @DisplayName("400 when wallet already exists for user")
        void create_400_duplicate() throws Exception {
            WalletsRequest req = WalletsRequest.builder().userId(1).balance(BigDecimal.TEN).build();
            when(service.create(any())).thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST));

            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isBadRequest());
        }
    }

    // ── PUT /{userId} ────────────────────────────────────────────────────────
    @Nested @DisplayName("PUT /{userId}")
    @SuppressWarnings("all")
class UpdateTests {

        @Test @DisplayName("200 on successful update")
        void update_200() throws Exception {
            WalletsRequest req = WalletsRequest.builder().userId(1).balance(new BigDecimal("500.00")).build();
            when(service.update(eq(1), any())).thenReturn(WalletsResponse.builder().userId(1).balance(new BigDecimal("500.00")).build());

            mvc.perform(put(BASE + "/1").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.balance").value(500.00));
        }

        @Test @DisplayName("404 when wallet to update not found")
        void update_404() throws Exception {
            WalletsRequest req = WalletsRequest.builder().userId(99).balance(BigDecimal.TEN).build();
            when(service.update(eq(99), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));

            mvc.perform(put(BASE + "/99").contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
               .andExpect(status().isNotFound());
        }
    }

    // ── DELETE /{userId} ─────────────────────────────────────────────────────
    @Nested @DisplayName("DELETE /{userId}")
    @SuppressWarnings("all")
class DeleteTests {

        @Test @DisplayName("204 on successful delete")
        void delete_204() throws Exception {
            doNothing().when(service).delete(1);
            mvc.perform(delete(BASE + "/1")).andExpect(status().isNoContent());
        }

        @Test @DisplayName("404 when wallet to delete not found")
        void delete_404() throws Exception {
            doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND)).when(service).delete(99);
            mvc.perform(delete(BASE + "/99")).andExpect(status().isNotFound());
        }
    }
}
