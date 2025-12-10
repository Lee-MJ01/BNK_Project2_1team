package kr.co.api.backend.schedule;


import kr.co.api.flobankapi.service.admin.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class ProductStatusScheduler {

    private final ProductService productService;

    // 매일 00:00:00 실행
    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Seoul")
    public void updateProductStatusByOpenDate() {

        log.info("상품 업데이트 시작");

        productService.updateOpenedProducts();

        log.info("상품 업데이트 완료!");
    }
}
