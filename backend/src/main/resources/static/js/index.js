// 로그인 필요 공통 이벤트 함수 (전역)
window.goKoAccountOpenMain = function () {
    const hasLoginFlag = document.cookie
        .split(";")
        .map(v => v.trim())
        .some(v => v.startsWith("loginYn=Y"));

    if (!hasLoginFlag) {
        alert("로그인 후 이용 부탁드립니다.");
        return;
    }
    window.location.href = "/flobank/mypage/account_open_main";
};

function getCookie(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(';').shift();
    return null;
}



document.addEventListener("DOMContentLoaded", () => {

    // API 공통 경로 상수 (서버 context-path에 맞춤)
    const CONTEXT_PATH = "/flobank";

    /** ============================
     * 1. 네비게이션 & Mega 메뉴
     * ============================ */
    const nav = document.querySelector(".nav-menu");
    const menuItems = document.querySelectorAll(".menu-item");
    const megaMenu = document.querySelector(".mega-menu");

    if (nav && menuItems.length && megaMenu) {
        menuItems.forEach((item) => {
            item.addEventListener("mouseenter", () => {
                megaMenu.classList.add("show");
                menuItems.forEach((i) => i.classList.remove("active"));
                item.classList.add("active");
            });
        });

        const wrapper = document.querySelector("header");
        let isInside = false;

        wrapper.addEventListener("mouseenter", () => { isInside = true; });

        wrapper.addEventListener("mouseleave", (e) => {
            const to = e.relatedTarget;
            if (!wrapper.contains(to)) {
                isInside = false;
                megaMenu.classList.remove("show");
                menuItems.forEach((i) => i.classList.remove("active"));
            }
        });

        window.addEventListener("scroll", () => {
            megaMenu.classList.remove("show");
            menuItems.forEach((i) => i.classList.remove("active"));
        });
    }

    /** ============================
     * 2. 검색 모달 (로그인 처리 & 자동완성 API 연동 완료)
     * ============================ */
    const searchTrigger = document.querySelector(".search-trigger");
    const searchModal = document.getElementById("searchModal");
    const closeButton = searchModal?.querySelector(".search-top-sheet__close");
    const searchForm = searchModal?.querySelector(".search-top-sheet__form");
    const searchInput = document.getElementById("globalSearch");

// 기존 결과 목록 요소 선택
    const recentList = searchModal?.querySelector('.search-section:nth-of-type(1) .search-list');
    const popularList = searchModal?.querySelector('.search-section:nth-of-type(2) .search-list.rank');

// [추가] 자동완성 관련 요소 선택 (HTML에 추가한 id="autocompleteList")
    const autocompleteList = document.getElementById("autocompleteList");
// [추가] 최근/인기 검색어를 감싸고 있는 컨텐츠 영역 (자동완성 시 숨기기 위함)
    const defaultSearchContent = searchModal?.querySelector(".search-top-sheet__content");

    if (searchTrigger && searchModal) {

        // -------------------------------------------------------
        // [유틸] 디바운스 함수 (연속 입력 시 API 호출 방지)
        // -------------------------------------------------------
        function debounce(func, delay) {
            let timeoutId;
            return function (...args) {
                clearTimeout(timeoutId);
                timeoutId = setTimeout(() => {
                    func.apply(this, args);
                }, delay);
            };
        }

        // --- [내부 함수] API 호출 (JWT 토큰 포함) ---
        async function fetchKeywords(url) {
            try {
                let token = localStorage.getItem('accessToken');
                if (!token) {
                    token = getCookie('accessToken');
                }

                const headers = { 'Content-Type': 'application/json' };
                if (token) headers['Authorization'] = `Bearer ${token}`;

                const response = await fetch(url, { headers: headers });

                if (!response.ok) return [];
                return await response.json();
            } catch (error) {
                console.error("데이터 로드 실패:", error);
                return [];
            }
        }

        // -------------------------------------------------------
        // [신규] 자동완성 API 호출
        // -------------------------------------------------------
        async function fetchAutocomplete(keyword) {

            // 검색어가 없으면 자동완성 숨기고 함수 종료
            if (!keyword || keyword.trim().length < 1) {
                hideAutocomplete();
                return;
            }

            try {
                const url = `${CONTEXT_PATH}/api/search/autocomplete?keyword=${encodeURIComponent(keyword)}`;

                // 토큰 로직 (필요시)
                let token = localStorage.getItem('accessToken');
                if (!token) token = getCookie('accessToken');

                const headers = { 'Content-Type': 'application/json' };
                if (token) headers['Authorization'] = `Bearer ${token}`;

                const response = await fetch(url, { headers: headers });

                if (response.ok) {
                    const suggestions = await response.json();
                    renderAutocomplete(suggestions, keyword);
                }
            } catch (error) {
                console.error("자동완성 로드 실패:", error);
            }
        }

        // -------------------------------------------------------
        // [신규] 자동완성 목록 렌더링
        // -------------------------------------------------------
        function renderAutocomplete(suggestions, keyword) {
            // 결과가 없으면 아무것도 안 하거나 숨김
            if (!suggestions || suggestions.length === 0) {
                return;
            }

            // 2. 자동완성 목록 보이기
            if (autocompleteList) {
                autocompleteList.style.display = 'block';
                autocompleteList.innerHTML = '';

                suggestions.forEach(text => {
                    const li = document.createElement('li');

                    // 하이라이팅: 검색어와 일치하는 부분 강조
                    const regex = new RegExp(`(${keyword})`, 'gi');
                    const highlightedText = text.replace(regex, '<span style="color:#2C5DE5; font-weight:bold;">$1</span>');

                    li.innerHTML = highlightedText;

                    // 클릭 시 검색 실행
                    li.addEventListener('click', () => {
                        searchInput.value = text;
                        goSearch(text);
                    });

                    autocompleteList.appendChild(li);
                });
            }
        }

        // -------------------------------------------------------
        // 자동완성 숨기기 (초기 화면 복구)
        // -------------------------------------------------------
        function hideAutocomplete() {
            if (autocompleteList) {
                autocompleteList.style.display = 'none';
                autocompleteList.innerHTML = '';
            }
        }

        // --- [내부 함수] 검색 실행 및 페이지 이동 ---
        function goSearch(keyword) {
            if (!keyword || keyword.trim().length < 1) {
                alert('검색어를 입력해주세요.');
                if(searchInput) searchInput.focus();
                return;
            }

            closeModal();
            window.location.href = `${CONTEXT_PATH}/search?keyword=${encodeURIComponent(keyword)}`;
        }

        function renderRecentList(data) {
            if (!recentList) return;
            recentList.innerHTML = '';

            if (!data || data.length === 0) {
                const isLogin = document.cookie.split(';').some(v => v.trim().startsWith('loginYn=Y'));
                recentList.innerHTML = isLogin
                    ? '<li class="empty">최근 검색 내역이 없습니다.</li>'
                    : '<li class="empty">로그인 후 이용하실 수 있습니다.</li>';
                return;
            }

            data.forEach(item => {
                const li = document.createElement('li');
                li.innerHTML = `
                <a href="#" class="keyword-link">${item.keyword}</a>
                <span class="date">${item.date || ''}</span>
                <button type="button" class="btn-delete" aria-label="삭제">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            `;

                li.querySelector('.keyword-link').addEventListener('click', (e) => {
                    e.preventDefault();
                    goSearch(item.keyword);
                });

                const deleteBtn = li.querySelector('.btn-delete');
                deleteBtn.addEventListener('click', (e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    deleteKeyword(item.keyword, li);
                });

                recentList.appendChild(li);
            });
        }

        async function deleteKeyword(keyword, liElement) {
            try {
                const url = `${CONTEXT_PATH}/api/search/keywords?keyword=${encodeURIComponent(keyword)}`;
                const response = await fetch(url, {
                    method: 'DELETE',
                    credentials: 'include',
                    headers: { 'Content-Type': 'application/json' }
                });

                if (response.ok) {
                    liElement.remove();
                    if (recentList.querySelectorAll('li').length === 0) {
                        recentList.innerHTML = '<li class="empty">최근 검색 내역이 없습니다.</li>';
                    }
                } else {
                    console.error("[Delete] 삭제 실패");
                }
            } catch (error) {
                console.error("[Delete] 에러:", error);
            }
        }

        function renderPopularList(data) {
            if (!popularList) return;
            popularList.innerHTML = '';

            if (!data || data.length === 0) {
                popularList.innerHTML = '<li class="empty">인기 검색어가 없습니다.</li>';
                return;
            }

            data.forEach((item) => {
                const li = document.createElement('li');
                li.innerHTML = `<a href="#" class="keyword-link">${item.keyword}</a>`;

                li.querySelector('.keyword-link').addEventListener('click', (e) => {
                    e.preventDefault();
                    goSearch(item.keyword);
                });

                popularList.appendChild(li);
            });
        }

        async function loadSearchData() {
            // 1. 인기 검색어
            fetchKeywords(`${CONTEXT_PATH}/api/search/keywords/popular`)
                .then(data => renderPopularList(data));

            // 2. 최근 검색어
            const isLogin = document.cookie.split(';').some(v => v.trim().startsWith('loginYn=Y'));
            if (isLogin) {
                fetchKeywords(`${CONTEXT_PATH}/api/search/keywords/recent`)
                    .then(data => renderRecentList(data));
            } else {
                renderRecentList([]);
            }
        }

        // --- 모달 제어 함수 ---
        const openModal = () => {
            searchModal.classList.add("open");
            searchModal.setAttribute("aria-hidden", "false");
            document.body.classList.add("modal-open");

            if(searchInput) {
                searchInput.value = '';
                // ✨ [추가] 모달 열 때 자동완성 숨기고 초기화
                hideAutocomplete();
                setTimeout(() => searchInput.focus(), 150);
            }

            loadSearchData();
        };

        const closeModal = () => {
            searchModal.classList.remove("open");
            searchModal.setAttribute("aria-hidden", "true");
            document.body.classList.remove("modal-open");
            searchTrigger.focus();
        };

        // --- 이벤트 리스너 등록 ---

        // 1. 검색창 입력 이벤트 (디바운스 적용)
        if (searchInput) {
            const onInputHandler = debounce((e) => {
                const keyword = e.target.value.trim();
                fetchAutocomplete(keyword);
            }, 300); // 0.3초 딜레이

            searchInput.addEventListener('input', onInputHandler);

            // 포커스 시에도 값이 있으면 자동완성 시도
            searchInput.addEventListener('focus', () => {
                if(searchInput.value.trim().length > 0) {
                    fetchAutocomplete(searchInput.value.trim());
                }
            });
        }

        // 2. 외부 클릭 시 자동완성 닫기
        document.addEventListener('click', (e) => {
            // 검색 폼 외부를 클릭했을 때 자동완성 창만 닫기
            if (searchForm && !searchForm.contains(e.target)) {
                if(autocompleteList) autocompleteList.style.display = 'none';
            }
        });

        searchTrigger.addEventListener("click", (e) => {
            e.preventDefault();
            openModal();
        });

        closeButton?.addEventListener("click", closeModal);

        searchForm?.addEventListener("submit", (e) => {
            e.preventDefault();
            const keyword = searchInput.value.trim();
            goSearch(keyword);
        });

        searchModal.addEventListener("click", (e) => {
            if (e.target === searchModal) closeModal();
        });

        document.addEventListener("keydown", (e) => {
            if (e.key === "Escape" && searchModal.classList.contains("open"))
                closeModal();
        });
    }

    /** ============================
     *  3. 슬라이드 배너 (기존 코드 유지)
     * ============================ */
    const slideWrapper = document.querySelector(".slides");
    const slides = document.querySelectorAll(".slide");
    const dots = document.querySelectorAll(".dot");
    const prevBtn = document.querySelector(".prev");
    const nextBtn = document.querySelector(".next");

    if (slideWrapper && slides.length) {
        slideWrapper.style.width = `${slides.length * 100}%`;
        slides.forEach(
            (slide) => (slide.style.flex = `0 0 ${100 / slides.length}%`)
        );

        let current = 0;
        let slideInterval;
        const intervalTime = 3000;

        function showSlide(index) {
            slideWrapper.style.transition = "transform 0.8s ease-in-out";
            slideWrapper.style.transform = `translateX(-${
                index * (100 / slides.length)
            }%)`;
            dots.forEach((dot) => dot.classList.remove("active"));
            dots[index].classList.add("active");
        }

        function nextSlide() {
            current = (current + 1) % slides.length;
            showSlide(current);
        }

        function prevSlide() {
            current = (current - 1 + slides.length) % slides.length;
            showSlide(current);
        }

        function startAutoSlide() {
            slideInterval = setInterval(nextSlide, intervalTime);
        }

        function stopAutoSlide() {
            clearInterval(slideInterval);
        }

        slideWrapper.addEventListener("mouseenter", stopAutoSlide);
        slideWrapper.addEventListener("mouseleave", startAutoSlide);
        nextBtn?.addEventListener("click", () => {
            nextSlide();
            stopAutoSlide();
            startAutoSlide();
        });
        prevBtn?.addEventListener("click", () => {
            prevSlide();
            stopAutoSlide();
            startAutoSlide();
        });
        dots.forEach((dot, index) => {
            dot.addEventListener("click", () => {
                current = index;
                showSlide(current);
                stopAutoSlide();
                startAutoSlide();
            });
        });

        showSlide(current);
        startAutoSlide();
    }

    /** ============================
     * 4. 언어 선택 드롭다운 (기존 코드 유지)
     * ============================ */
    const langToggle = document.querySelector(".language-toggle");
    const langMenu = document.querySelector(".language-menu");

    if (langToggle && langMenu) {
        langToggle.addEventListener("click", (e) => {
            e.preventDefault();
            langMenu.classList.toggle("show");
        });

        document.addEventListener("click", (e) => {
            if (!e.target.closest(".language-dropdown")) {
                langMenu.classList.remove("show");
            }
        });

        langMenu.querySelectorAll("li").forEach((item) => {
            item.addEventListener("click", () => {
                const lang = item.dataset.lang;
                localStorage.setItem("selectedLang", lang);
                window.location.reload();
            });
        });
    }

    /** ============================
     *  5. 페이지 텍스트 자동 번역 기능 (기존 코드 유지)
     * ============================ */
    const selectedLang = localStorage.getItem("selectedLang") || "ko";

    function getTextNodes(node, nodes = []) {
        if (node.nodeType === Node.TEXT_NODE && node.textContent.trim() !== "") {
            nodes.push(node);
        }
        node.childNodes.forEach((child) => getTextNodes(child, nodes));
        return nodes;
    }

    async function translateText(text, targetLang) {
        const response = await fetch(`${CONTEXT_PATH}/api/translate`, {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({
                text: text,
                targetLang: targetLang
            })
        });

        const data = await response.json();
        return data.translatedText;
    }

    async function translatePage(targetLang) {
        if (targetLang === "ko") return;

        const nodes = getTextNodes(document.body);

        for (const node of nodes) {
            const original = node.textContent.trim();
            try {
                const translated = await translateText(original, targetLang);
                if(translated) node.textContent = translated;
            } catch(e) {
                console.warn("Translation failed for node", e);
            }
        }
    }
    translatePage(selectedLang);
});