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

import zentry.back.api.business.controllers.AdImpressionsController;
import zentry.back.api.business.dtos.AdImpressionsRequest;
import zentry.back.api.business.dtos.AdImpressionsResponse;
import zentry.back.api.business.services.AdImpressionsService;
import zentry.back.api.config.SecurityConfig;

import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Import({SecurityConfig.class, TestSecurityBeansConfig.class})
@WebMvcTest(AdImpressionsController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("AdImpressionsController")
@SuppressWarnings("all")
class AdImpressionsControllerTest {

    @Autowired
    MockMvc mvc;
    @Autowired
    ObjectMapper json;
    @MockitoBean
    AdImpressionsService service;

    private static final String BASE = "/api/business/ad-impressions";
    private final UUID id = UUID.randomUUID();
    private static final UUID campaignUuid = UUID.randomUUID();

    private AdImpressionsResponse sample() {
        return AdImpressionsResponse.builder().id(id).campaignId(campaignUuid).vistas(100).build();
    }

    @Nested
    @DisplayName("GET /")
    class ListTests {
        @Test
        void list_200() throws Exception {
            when(service.list(any(Pageable.class))).thenReturn(new PageImpl<>(List.of(sample())));
            mvc.perform(get(BASE)).andExpect(status().isOk())
                    .andExpect(jsonPath("$.content[0].vistas").value(100));
        }
    }

    @Nested
    @DisplayName("GET /{id}")
    class GetByIdTests {
        @Test
        void found() throws Exception {
            when(service.getById(id)).thenReturn(sample());
            mvc.perform(get(BASE + "/" + id)).andExpect(status().isOk())
                    .andExpect(jsonPath("$.vistas").value(100));
        }

        @Test
        void notFound() throws Exception {
            UUID u = UUID.randomUUID();
            when(service.getById(u)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(get(BASE + "/" + u)).andExpect(status().isNotFound());
        }
    }

    @Nested
    @DisplayName("POST /")
    class CreateTests {
        @Test
        void create_201() throws Exception {
            AdImpressionsRequest req = AdImpressionsRequest.builder().campaignId(campaignUuid).vistas(200).build();
            when(service.create(any())).thenReturn(
                    AdImpressionsResponse.builder().id(UUID.randomUUID()).campaignId(campaignUuid).vistas(200).build());
            mvc.perform(post(BASE).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
                    .andExpect(status().isCreated()).andExpect(jsonPath("$.vistas").value(200));
        }
    }

    @Nested
    @DisplayName("PUT /{id}")
    class UpdateTests {
        @Test
        void update_200() throws Exception {
            AdImpressionsRequest req = AdImpressionsRequest.builder().campaignId(campaignUuid).vistas(500).build();
            when(service.update(eq(id), any()))
                    .thenReturn(AdImpressionsResponse.builder().id(id).campaignId(campaignUuid).vistas(500).build());
            mvc.perform(
                    put(BASE + "/" + id).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(req)))
                    .andExpect(status().isOk()).andExpect(jsonPath("$.vistas").value(500));
        }

        @Test
        void update_404() throws Exception {
            UUID u = UUID.randomUUID();
            when(service.update(eq(u), any())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND));
            mvc.perform(put(BASE + "/" + u).contentType(MediaType.APPLICATION_JSON)
                    .content(json.writeValueAsString(AdImpressionsRequest.builder().campaignId(campaignUuid).vistas(1).build())))
                    .andExpect(status().isNotFound());
        }
    }

    @Nested
    @DisplayName("DELETE /{id}")
    class DeleteTests {
        @Test
        void delete_204() throws Exception {
            doNothing().when(service).delete(id);
            mvc.perform(delete(BASE + "/" + id)).andExpect(status().isNoContent());
        }

        @Test
        void delete_404() throws Exception {
            UUID u = UUID.randomUUID();
            doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND)).when(service).delete(u);
            mvc.perform(delete(BASE + "/" + u)).andExpect(status().isNotFound());
        }
    }
}
