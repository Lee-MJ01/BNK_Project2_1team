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

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import java.text.NumberFormat;
import java.util.Locale;
import java.util.Optional;

@RestController
@RequestMapping("/deposit")
public class DepositApiController {

    private final DepositMapper depositMapper;

    public DepositApiController(DepositMapper depositMapper) {
        this.depositMapper = depositMapper;
    }

    /**
     * 활성화된 예금 상품 목록을 조회
     */
    @GetMapping("/products")
    public List<DepositListResponse> getActiveProducts() {
        List<ProductDTO> products = depositMapper.findActiveProducts();
        return products.stream()
                .map(p -> new DepositListResponse(p.getDpstId(), p.getDpstName(), p.getDpstInfo()))
                .collect(Collectors.toList());
    }

    /**
     * 단일 예금 상품 상세 정보를 조회
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


    /**
     * 예금 신규 가입 신청 (프론트 연동용)
     */
    @PostMapping("/applications")
    public ResponseEntity<Map<String, Object>> applyDeposit(
            @RequestBody Map<String, Object> request
    ) {
        Map<String, Object> response = new HashMap<>();

        String dpstId = Objects.toString(request.get("dpstId"), "");
        ProductDTO product = dpstId.isEmpty() ? null : depositMapper.findProductById(dpstId);

        String productName = Optional.ofNullable(product)
                .map(ProductDTO::getDpstName)
                .orElse("외화정기예금");

        String currency = Objects.toString(request.get("newCurrency"), "");
        String periodLabel = request.get("newPeriodMonths") != null
                ? request.get("newPeriodMonths") + "개월"
                : "-";

        String withdrawType = Objects.toString(request.get("withdrawType"), "krw");
        String withdrawalAccount = Objects.toString(
                "fx".equalsIgnoreCase(withdrawType)
                        ? request.get("selectedFxAccount")
                        : request.get("selectedKrwAccount"),
                ""
        );

        String withdrawCurrency = "fx".equalsIgnoreCase(withdrawType)
                ? Objects.toString(request.get("fxWithdrawCurrency"), "")
                : "KRW";

        String amount = formatAmount(request.get("newAmount"), currency);

        String autoRenew = Objects.toString(request.get("autoRenew"), "no");
        String autoRenewLabel = "apply".equalsIgnoreCase(autoRenew)
                ? buildAutoRenewLabel(request.get("autoRenewCycle"))
                : "미신청";

        response.put("dpstId", dpstId);

        response.put("customerName", "홍길동");
        response.put("productName", productName);

        response.put("newAccountNo", "123-456-789012");
        response.put("currency", currency);
        response.put("amount", amount);
        response.put("withdrawalAccount", withdrawalAccount);
        response.put("withdrawCurrency", withdrawCurrency);
        response.put("withdrawAmount", amount);

        response.put("rate", "3.5%");
        response.put("maturityDate", "2026-09-18");



        response.put("periodLabel", periodLabel);
        response.put("autoRenewLabel", autoRenewLabel);


        response.put("contractDateTime", LocalDateTime.now().toString());

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }


    private String formatAmount(Object amountObj, String currency) {
        if (amountObj == null) {
            return currency.isEmpty() ? "-" : currency + " -";
        }

        long amount;
        if (amountObj instanceof Number number) {
            amount = number.longValue();
        } else {
            try {
                amount = Long.parseLong(amountObj.toString());
            } catch (NumberFormatException e) {
                return amountObj.toString();
            }
        }

        NumberFormat formatter = NumberFormat.getNumberInstance(Locale.KOREA);
        return currency.isEmpty()
                ? formatter.format(amount)
                : currency + " " + formatter.format(amount);
    }

    private String buildAutoRenewLabel(Object cycleObj) {
        if (cycleObj == null) {
            return "신청 (주기 미입력)";
        }

        String cycle = cycleObj.toString();
        return cycle.isEmpty()
                ? "신청 (주기 미입력)"
                : "신청 - " + cycle + "개월 주기";
    }




}