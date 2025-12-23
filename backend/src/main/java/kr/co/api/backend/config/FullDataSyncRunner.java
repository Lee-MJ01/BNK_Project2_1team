package kr.co.api.backend.config;

import kr.co.api.backend.document.*;
import kr.co.api.backend.mapper.SearchDataMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.IndexOperations;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class FullDataSyncRunner implements ApplicationRunner {

    private final SearchDataMapper searchDataMapper;
    private final ElasticsearchOperations elasticsearchOperations;

    @Override
    @Transactional(readOnly = true)
    public void run(ApplicationArguments args) throws Exception {


        //  1. 모든 인덱스 강제 재생성 (기존 데이터 삭제 후 Nori 설정 적용)
        recreateIndex(ProductDocument.class);
        recreateIndex(FaqDocument.class);
        recreateIndex(NoticeDocument.class);
        recreateIndex(EventDocument.class);
        recreateIndex(TermDocument.class);



        try {
            syncProducts();
            syncFaqs();
            syncTerms();
            syncNotices();
            syncEvents();


        } catch (Exception e) {
        }
    }

    // =============================================================
    //  인덱스를 삭제하고 설정 파일대로 다시 만드는 함수
    // =============================================================
    private void recreateIndex(Class<?> clazz) {
        IndexOperations indexOps = elasticsearchOperations.indexOps(clazz);

        // 1. 기존 인덱스 삭제
        if (indexOps.exists()) {
            indexOps.delete();
        }

        // 2. @Setting과 @Mapping 파일을 읽어서 인덱스 생성
        // (주의: createWithMapping이 안 되면 create() + putMapping() 조합 사용)
        indexOps.createWithMapping();

        indexOps.refresh();
    }

    // -----------------------------------------------------------------
    // [유틸] 단어 쪼개기 헬퍼 함수 (모든 동기화 메서드에서 사용)
    // "환율CARE 외화예금" -> ["환율CARE 외화예금", "환율CARE", "외화예금"]
    // -----------------------------------------------------------------
    private Completion createSplitCompletion(String fullTitle) {
        if (fullTitle == null) return null;

        String[] words = fullTitle.split(" ");
        String[] inputs = new String[words.length + 1];

        // 0번 인덱스에 전체 문장 넣기
        inputs[0] = fullTitle;
        // 1번부터 쪼갠 단어들 넣기
        System.arraycopy(words, 0, inputs, 1, words.length);

        return new Completion(inputs);
    }

    // -----------------------------------------------------------------
    // 1. 상품 데이터 동기화
    // -----------------------------------------------------------------
    private void syncProducts() {
        List<ProductDocument> list = searchDataMapper.selectAllProducts();
        if (list != null && !list.isEmpty()) {
            for (ProductDocument item : list) {
                // 헬퍼 함수 사용해서 자동완성 데이터 생성
                item.setSuggest(createSplitCompletion(item.getDpstName()));
            }
            elasticsearchOperations.save(list);
        }
    }

    // -----------------------------------------------------------------
    // 2. FAQ 데이터 동기화
    // -----------------------------------------------------------------
    private void syncFaqs() {
        List<FaqDocument> list = searchDataMapper.selectAllFaqs();
        if (list != null && !list.isEmpty()) {
            for (FaqDocument item : list) {
                // 질문(Question)을 기준으로 쪼개서 넣기
                item.setSuggest(createSplitCompletion(item.getFaqQuestion()));
            }
            elasticsearchOperations.save(list);
        }
    }

    // -----------------------------------------------------------------
    // 3. 약관 데이터 동기화
    // -----------------------------------------------------------------
    private void syncTerms() {
        List<TermDocument> list = searchDataMapper.selectAllTerms();

        if (list != null && !list.isEmpty()) {
            for (TermDocument term : list) {
                if (term.getThistContent() == null) term.setThistContent("");
                if (term.getTermTitle() == null) term.setTermTitle("제목 없음");
                term.setGroupKey(term.getTermTitle().trim());
                term.setSuggest(createSplitCompletion(term.getTermTitle()));
            }
            elasticsearchOperations.save(list);
        }
    }

    // -----------------------------------------------------------------
    // 4. 공지사항 데이터 동기화
    // -----------------------------------------------------------------
    private void syncNotices() {
        List<NoticeDocument> list = searchDataMapper.selectAllNotices();
        if (list != null && !list.isEmpty()) {
            for (NoticeDocument notice : list) {
                if (notice.getBoardContent() == null) notice.setBoardContent("");

                // 공지 제목을 기준으로 쪼개서 넣기
                notice.setSuggest(createSplitCompletion(notice.getBoardTitle()));
            }
            elasticsearchOperations.save(list);
        }
    }

    // -----------------------------------------------------------------
    // 5. 이벤트 데이터 동기화
    // -----------------------------------------------------------------
    private void syncEvents() {
        List<EventDocument> list = searchDataMapper.selectAllEvents();
        if (list != null && !list.isEmpty()) {
            for (EventDocument event : list) {
                if (event.getBoardContent() == null) event.setBoardContent("");
                if (event.getEventBenefit() == null) event.setEventBenefit("");

                // 이벤트 제목을 기준으로 쪼개서 넣기
                event.setSuggest(createSplitCompletion(event.getBoardTitle()));
            }
            elasticsearchOperations.save(list);
        }
    }
}