package kr.co.api.backend.service.admin;

import kr.co.api.flobankapi.config.FilePathConfig;
import kr.co.api.flobankapi.dto.*;
import kr.co.api.flobankapi.mapper.admin.ProductMapper;
import kr.co.api.flobankapi.service.PdfAiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.*;

@Slf4j
@RequiredArgsConstructor
@Service
public class ProductService {

    private final ProductMapper productMapper;
    private final FilePathConfig filePathConfig;
    private final PdfAiService pdfAiService;

    /**
     * 상품 등록 (파일 업로드 포함)
     */
    @Transactional
    public void insertProduct(ProductDTO dto,
                              List<ProductLimitDTO> limits,
                              List<ProductPeriodDTO> periods,
                              ProductWithdrawRuleDTO wdrwInfo,
                              List<ProductWithdrawAmtDTO> withdrawAmts,
                              MultipartFile pdfFile,
                              String selectedPdfPath,
                              String selectedPdfName,
                              Long selectedPdfId) throws Exception {

        // 1. 파일 업로드 처리
        dto.setDpstInfoPdf(null); // 초기화

        if (pdfFile != null && !pdfFile.isEmpty()) {
            String savedPath = saveProductPdf(pdfFile);
            dto.setDpstInfoPdf(savedPath);
        } else if (StringUtils.hasText(selectedPdfPath) && StringUtils.hasText(selectedPdfName)) {
            String savedPath = copyAiPdfToProducts(selectedPdfPath, selectedPdfName);
            dto.setDpstInfoPdf(savedPath);
            pdfAiService.markPdfAsUsed(selectedPdfId);
        }

        // 2. 상품 기본 정보 DB 저장 (여기서 dpstId 생성됨)
        productMapper.insertProduct(dto);
        String dpstId = dto.getDpstId();

        // 3. 한도 설정 (중복 제거 후 저장)
        if (limits != null && !limits.isEmpty()) {
            List<ProductLimitDTO> clean = new ArrayList<>();
            Set<String> seen = new HashSet<>();
            for (ProductLimitDTO l : limits) {
                if (l.getLmtCurrency() == null || l.getLmtCurrency().trim().isEmpty()) continue;
                if (seen.add(l.getLmtCurrency())) clean.add(l);
            }

            // 거치식(1)이고 한도 데이터가 있을 때만 저장
            if (dto.getDpstType() == 1 && !clean.isEmpty()) {
                Map<String, Object> map = new HashMap<>();
                map.put("dpstId", dpstId);
                map.put("limits", clean);
                productMapper.insertProductLimits(map);
            }
        }

        // 4. 가입기간 저장
        if (periods != null && !periods.isEmpty()) {
            Map<String, Object> map2 = new HashMap<>();
            map2.put("dpstId", dpstId);
            map2.put("list", periods);
            productMapper.insertProductPeriods(map2);
        }

        // 5. 분할 인출 규정 저장
        if (wdrwInfo != null) {
            wdrwInfo.setDpstId(dpstId);
            productMapper.insertWithdrawalRule(wdrwInfo);
        }

        // 6. 통화별 최소 출금금액 저장
        if (withdrawAmts != null && !withdrawAmts.isEmpty()) {
            Map<String, Object> map3 = new HashMap<>();
            map3.put("dpstId", dpstId);
            map3.put("list", withdrawAmts);
            productMapper.insertWithdrawalAmounts(map3);
        }
    }

    /**
     * 파일 저장 로직 (내부용)
     */
    private String saveProductPdf(MultipartFile file) throws Exception {
        String basePath = resolveProductsBasePath();

        String original = file.getOriginalFilename();
        String safeName = StringUtils.cleanPath(original);
        String storedName = UUID.randomUUID() + "_" + safeName;

        File folder = new File(basePath);
        if (!folder.exists()) {
            folder.mkdirs(); // 폴더가 없으면 강제 생성
        }

        File dest = new File(folder, storedName);
        if (!dest.isAbsolute()) {
            dest = dest.getAbsoluteFile();
        }

        file.transferTo(dest);

        return "/uploads/pdf_products/" + storedName;
    }

    private String copyAiPdfToProducts(String sourcePath, String storedFileName) throws Exception {
        String basePath = resolveProductsBasePath();

        Path targetDir = Path.of(basePath);
        Files.createDirectories(targetDir);

        Path sourceFile = Path.of(sourcePath);
        if (!Files.exists(sourceFile)) {
            throw new IllegalArgumentException("선택한 AI PDF 파일을 찾을 수 없습니다.");
        }

        Path targetFile = targetDir.resolve(storedFileName);
        Files.copy(sourceFile, targetFile, StandardCopyOption.REPLACE_EXISTING);

        return "/uploads/pdf_products/" + storedFileName;
    }

    private String resolveProductsBasePath() {
        String basePath = filePathConfig.getPdfProductsPath();

        if (basePath == null || basePath.isBlank()) {
            basePath = "/app/uploads/pdf_products";
        }

        return basePath;
    }

    // --- 조회 메서드들 ---

    public List<ProductDTO> getProductsByStatus(int status) {
        return productMapper.getProductsByStatus(status);
    }

    public void updateStatus(String dpstId, int status) {
        productMapper.updateStatus(dpstId, status);
    }

    public ProductDTO getProductById(String dpstId) {
        return productMapper.getProductById(dpstId);
    }

    public List<ProductPeriodDTO> getPeriods(String dpstId) {
        return productMapper.getPeriods(dpstId);
    }

    public ProductWithdrawRuleDTO getWithdrawRule(String dpstId) {
        return productMapper.getWithdrawRule(dpstId);
    }

    public List<ProductWithdrawAmtDTO> getWithdrawAmts(String dpstId) {
        return productMapper.getWithdrawAmts(dpstId);
    }

    public List<ProductLimitDTO> getLimits(String dpstId) {
        return productMapper.getLimits(dpstId);
    }

    public void updateOpenedProducts() {
        productMapper.updateStatusToOpened();
    }

    // 관리자용 약관 파일 확인 메서드
    public String getTermsFileByName(String productName) {
        return productMapper.findTermsFileByTitle(productName);
    }
}