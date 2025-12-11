package kr.co.api.backend.controller.admin;

import jakarta.servlet.http.HttpServletRequest;
import kr.co.api.flobankapi.dto.*;
import kr.co.api.flobankapi.service.admin.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/products")
public class ProductController {

    private final ProductService productService;

    @GetMapping("")
    public String productList(Model model) {
        model.addAttribute("activeItem", "products");

        model.addAttribute("approveList", productService.getProductsByStatus(1));
        model.addAttribute("pendingList", productService.getProductsByStatus(2));
        model.addAttribute("saleList", productService.getProductsByStatus(3));
        model.addAttribute("stopList", productService.getProductsByStatus(4));

        return "admin/products";
    }




    @GetMapping("/view/{dpstId}")
    public String productView(@PathVariable String dpstId, Model model) {

        ProductDTO product = productService.getProductById(dpstId);

        // 기간 목록
        List<ProductPeriodDTO> periods = productService.getPeriods(dpstId);

        // 일부인출 규정
        ProductWithdrawRuleDTO wdrwRule = productService.getWithdrawRule(dpstId);

        // 통화별 최소출금액
        List<ProductWithdrawAmtDTO> wdrwAmts = productService.getWithdrawAmts(dpstId);

        // 최소/최대 가입액 제한
        List<ProductLimitDTO> limits = productService.getLimits(dpstId);

        String termsFilePath = productService.getTermsFileByName(product.getDpstName());


        model.addAttribute("product", product);
        model.addAttribute("periods", periods);
        model.addAttribute("withdrawRule", wdrwRule);
        model.addAttribute("withdrawAmts", wdrwAmts);
        model.addAttribute("limits", limits);
        model.addAttribute("termsFilePath", termsFilePath);

        return "admin/products_view";
    }







    @PostMapping("/register")
    public String registerProduct(
            ProductDTO dto,
            @RequestParam(value = "pdfFile", required = false) MultipartFile pdfFile,

            @RequestParam(value = "dpstCurrency", required = false) String[] currencies,
            @RequestParam("ageLimit") String ageLimit,
            @RequestParam(value="lmtCurrency", required = false) String[] lmtCurrency,
            @RequestParam(value="lmtMinAmt", required = false) Integer[] lmtMinAmt,
            @RequestParam(value="lmtMaxAmt", required = false) Integer[] lmtMaxAmt,
            @RequestParam(value="minMonths", required = false) Integer minMonths,
            @RequestParam(value="maxMonths", required = false) Integer maxMonths,
            @RequestParam(value="fixedMonths", required = false) String fixedMonths,
            @RequestParam(value="withdrawAfterMonths", required = false) Integer withdrawAfterMonths,
            @RequestParam(value="withdrawCount", required = false) Integer withdrawCount,
            @RequestParam(value = "selectedPdfPath", required = false) String selectedPdfPath,
            @RequestParam(value = "selectedPdfName", required = false) String selectedPdfName,
            @RequestParam(value = "selectedPdfId", required = false) Long selectedPdfId,
            HttpServletRequest request
    ) throws Exception {

    /* -----------------------------
       통화 처리
    ------------------------------ */
        if (currencies != null) {
            dto.setDpstCurrency(String.join(",", currencies));
        }

    /* -----------------------------
       나이 제한 처리
    ------------------------------ */
        if (ageLimit.equals("none")) {
            dto.setDpstMinAge(null);
            dto.setDpstMaxAge(null);
        }

    /* -----------------------------
       최소/최대 가입액 처리
    ------------------------------ */
        // 최소/최대 가입액 처리
        List<ProductLimitDTO> limits = new ArrayList<>();

        // 1) 거치식일 때만 limits 생성
        if (dto.getDpstType() == 1 && currencies != null) {
            for (int i = 0; i < currencies.length; i++) {
                ProductLimitDTO limit = new ProductLimitDTO();
                limit.setLmtCurrency(currencies[i]);
                limit.setLmtMinAmt(lmtMinAmt[i]);
                limit.setLmtMaxAmt(lmtMaxAmt[i]);
                limits.add(limit);
            }
        }

        // 2) 예금유형이 1이 아니면 비우기
        if (dto.getDpstType() != 1) {
            limits = new ArrayList<>();
        }

        // 3) 중복 통화 제거
        Set<String> seen = new HashSet<>();
        List<ProductLimitDTO> deduped = new ArrayList<>();
        for (ProductLimitDTO l : limits) {
            if (seen.add(l.getLmtCurrency())) {
                deduped.add(l);
            }
        }
        limits = deduped;



        boolean hasMin = limits.stream().anyMatch(l -> l.getLmtMinAmt() != null);
        boolean hasMax = limits.stream().anyMatch(l -> l.getLmtMaxAmt() != null);

        dto.setDpstMinYn(hasMin ? "Y" : "N");
        dto.setDpstMaxYn(hasMax ? "Y" : "N");

        dto.setDpstStatus(1);


    /* -----------------------------
       가입 기간(periods) 생성
    ------------------------------ */
        List<ProductPeriodDTO> periods = new ArrayList<>();

        if (dto.getDpstPeriodType() == 1) {
            // 자유형
            ProductPeriodDTO p = new ProductPeriodDTO();
            p.setMinMonth(minMonths);
            p.setMaxMonth(maxMonths);
            periods.add(p);

        } else if (dto.getDpstPeriodType() == 2) {
            // 고정형
            if (fixedMonths != null && !fixedMonths.isEmpty()) {
                String[] arr = fixedMonths.split(",");
                for (String m : arr) {
                    ProductPeriodDTO p = new ProductPeriodDTO();
                    p.setFixedMonth(Integer.parseInt(m.trim()));
                    periods.add(p);
                }
            }
        }


    /* -----------------------------
       분할 인출 규정 생성
    ------------------------------ */
        ProductWithdrawRuleDTO wdrwInfo = null;

        if ("Y".equals(dto.getDpstPartWdrwYn())) {
            wdrwInfo = new ProductWithdrawRuleDTO();
            wdrwInfo.setMinMonths(withdrawAfterMonths);
            wdrwInfo.setMaxCount(withdrawCount);
        }


    /* -----------------------------
       통화별 최소 출금 금액 생성
    ------------------------------ */
        List<ProductWithdrawAmtDTO> withdrawAmts = new ArrayList<>();

        if ("Y".equals(dto.getDpstPartWdrwYn()) && dto.getDpstType() == 1) {



            if (currencies != null) {
                for (String cur : currencies) {
                    String paramName = "minWithdraw_" + cur;
                    String val = request.getParameter(paramName);

                    if (val != null && !val.isEmpty()) {
                        ProductWithdrawAmtDTO amt = new ProductWithdrawAmtDTO();
                        amt.setCurrency(cur);
                        amt.setMinAmt(Integer.parseInt(val));
                        withdrawAmts.add(amt);
                    }
                }
            }
        }


    /* -----------------------------
       최종 저장
    ------------------------------ */
        productService.insertProduct(dto, limits, periods, wdrwInfo, withdrawAmts, pdfFile, selectedPdfPath, selectedPdfName, selectedPdfId);

        return "redirect:/admin/products";
    }


    @PostMapping("/approve/{dpstId}")
    @ResponseBody
    public void approveProduct(@PathVariable String dpstId) {
        productService.updateStatus(dpstId, 2);
    }









}