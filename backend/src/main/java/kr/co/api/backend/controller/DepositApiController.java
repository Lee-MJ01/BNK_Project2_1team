package kr.co.api.backend.controller;

import kr.co.api.backend.dto.ProductDTO;
import kr.co.api.backend.dto.ProductLimitDTO;
import kr.co.api.backend.dto.ProductPeriodDTO;
import kr.co.api.backend.mapper.DepositMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/deposit")
public class DepositApiController {

    private final DepositMapper depositMapper;

    public DepositApiController(DepositMapper depositMapper) {
        this.depositMapper = depositMapper;
    }

    /**
     * 활성화된 예금 상품 목록을 조회한다.
     */
    @GetMapping("/products")
    public List<DepositListResponse> getActiveProducts() {
        List<ProductDTO> products = depositMapper.findActiveProducts();
        return products.stream()
                .map(p -> new DepositListResponse(p.getDpstId(), p.getDpstName(), p.getDpstInfo()))
                .collect(Collectors.toList());
    }

    /**
     * 단일 예금 상품 상세 정보를 조회한다.
     */
    @GetMapping("/products/{dpstId}")
    public ResponseEntity<DepositProductResponse> getProduct(@PathVariable String dpstId) {
        ProductDTO product = depositMapper.findProductById(dpstId);
        if (product == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(DepositProductResponse.from(product));
    }

    /**
     * 목록 조회 응답 DTO.
     */
    public record DepositListResponse(String dpstId, String dpstName, String dpstInfo) { }

    /**
     * 상세 조회 응답 DTO.
     */
    public record DepositProductResponse(
            String dpstId,
            String dpstName,
            String dpstDescript,
            String dpstInfo,
            String dpstCurrency,
            String dpstPartWdrwYn,
            String dpstAddPayYn,
            Integer dpstAddPayMaxCnt,
            List<ProductLimitDTO> limits,
            Integer periodMinMonth,
            Integer periodMaxMonth,
            Integer periodFixedMonth,
            String dpstDelibNo,
            String dpstDelibDy,
            String dpstDelibStartDy
    ) {
        public static DepositProductResponse from(ProductDTO product) {
            List<ProductLimitDTO> limits = product.getLimits();
            if (limits == null) {
                limits = Collections.emptyList();
            }

            Integer fixedMonth = product.getPeriodFixedMonth();
            if (fixedMonth == null && product.getPeriodList() != null) {
                fixedMonth = product.getPeriodList().stream()
                        .map(ProductPeriodDTO::getFixedMonth)
                        .filter(Objects::nonNull)
                        .findFirst()
                        .orElse(null);
            }

            Integer minMonth = product.getPeriodMinMonth();
            Integer maxMonth = product.getPeriodMaxMonth();
            if ((minMonth == null || maxMonth == null) && product.getPeriodList() != null) {
                for (var period : product.getPeriodList()) {
                    if (minMonth == null && period.getMinMonth() != null) {
                        minMonth = period.getMinMonth();
                    }
                    if (maxMonth == null && period.getMaxMonth() != null) {
                        maxMonth = period.getMaxMonth();
                    }
                    if (minMonth != null && maxMonth != null) {
                        break;
                    }
                }
            }

            return new DepositProductResponse(
                    product.getDpstId(),
                    product.getDpstName(),
                    product.getDpstDescript(),
                    product.getDpstInfo(),
                    product.getDpstCurrency(),
                    product.getDpstPartWdrwYn(),
                    product.getDpstAddPayYn(),
                    product.getDpstAddPayMax(),
                    limits,
                    minMonth,
                    maxMonth,
                    fixedMonth,
                    product.getDpstDelibNo(),
                    product.getDpstDelibDy(),
                    product.getDpstDelibStartDy()
            );
        }
    }
}