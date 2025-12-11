/* ============================================================================
   FLOBANK - Admin Exchange Dashboard Script
   - 기능:
     ✔ 7개 통화 자동 필터 생성 (USD, EUR, JPY, GBP, CNH, AUD, KRW)
     ✔ 데이터의 통화 값 중복/따옴표 제거 처리
     ✔ 날짜 선택 시 해당 날짜의 통화별 환전금액 표시
     ✔ 일자별 총 환전액 그래프 출력
     ✔ 5분 자동 새로고침
     ✔ Chart.js 기반 stacked bar chart
============================================================================ */
function getToday() {
    const d = new Date();
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    return `${d.getFullYear()}-${mm}-${dd}`;
}


(function () {

    /* -----------------------------------------------------------------------
       색상 팔레트 / 기본 통화 목록 선언
       - 기본 통화는 7개로 고정
    ----------------------------------------------------------------------- */
    const palette = ['#5c80c8', '#74b49b', '#f4a261', '#8e83c4', '#ff6b6b', '#2d6a4f', '#4d908e'];


    // 파스텔 팔레트 추가
    const pastelPalette = [
        'rgba(111, 185, 255, 0.7)', // 진한 하늘블루
        'rgba(140, 160, 255, 0.7)', // 라벤더-블루
        'rgba(255, 160, 160, 0.7)', // 소프트 레드 (선명)
        'rgba(255, 195, 125, 0.7)', // 오렌지-베이지 (따뜻함)
        'rgba(135, 200, 255, 0.7)', // 아쿠아-블루 (선명)
        'rgba(135, 225, 180, 0.7)', // 민트-그린 (쿨톤)
        'rgba(180, 190, 255, 0.7)'  // 라일락-블루
    ];



    // ✔ 표시할 모든 통화 7개
    const defaultCurrencies = ['USD', 'EUR', 'JPY', 'GBP', 'CNH', 'AUD', 'KRW'];

    // ✔ 기본 선택 통화 (첫 렌더링에 'USD' 선택)
    const selectedCurrencies = new Set(['USD']);

    // 차트 객체
    let currencyChart;
    let totalChart;

    // 선택된 날짜(yyyy-MM-dd)
    let selectedDate = '';

    // 기간 선택 상태
    let rangeMode = false;
    let rangeStartDate = '';
    let rangeEndDate = '';
    let rangeLabel = '';


    // 서버에서 Thymeleaf로 내려준 데이터
    let latestStats = window.exchangeStats || {};


    /* -----------------------------------------------------------------------
       숫자 compact(1억 → 1억, 1234000 → 123만 ) 포맷 처리
    ----------------------------------------------------------------------- */
    function compactNumber(value) {
        try {
            const formatter = new Intl.NumberFormat('ko-KR', {
                notation: 'compact',
                maximumFractionDigits: 1
            });
            return formatter.format(value);
        } catch (e) {
            return value.toLocaleString('ko-KR');
        }
    }


    /* -----------------------------------------------------------------------
       날짜 라벨 정제 (X축용: MM-DD만 표시)
    ----------------------------------------------------------------------- */
    function formatDateLabel(dateStr) {
        if (!dateStr) return "";

        dateStr = String(dateStr).trim().replace(/\s+/g, "");

        // YYYY-MM-DD → MM-DD
        const match = dateStr.match(/(\d{4})-(\d{2})-(\d{2})/);
        if (match) {
            return `${match[2]}-${match[3]}`;
        }

        // -11-20 같은 실수 제거
        dateStr = dateStr.replace(/^-+/, "");

        const short = dateStr.match(/(\d{2})-(\d{2})/);
        if (short) return short[0];

        return dateStr;
    }


    /* -----------------------------------------------------------------------
       통화 문자열 정제 (“USD” → USD)
    ----------------------------------------------------------------------- */
    function cleanCurrency(c) {
        return String(c).replace(/"/g, "").trim();
    }


    /* -----------------------------------------------------------------------
        날짜/시간 유틸
    ----------------------------------------------------------------------- */

    function normalizeDate(dateInput) {
        if (!dateInput) return '';
        const text = String(dateInput);
        const match = text.match(/\d{4}-\d{2}-\d{2}/);
        return match ? match[0] : '';
    }

    function deriveLatestDateFromStats(stats) {
        if (!stats) return '';
        const dates = [];

        (stats.currencyDailyAmounts || []).forEach(item => {
            const normalized = normalizeDate(item.baseDate);
            if (normalized) dates.push(normalized);
        });

        (stats.dailyTotals || []).forEach(item => {
            const normalized = normalizeDate(item.baseDate);
            if (normalized) dates.push(normalized);
        });

        const base = normalizeDate(stats.lastUpdatedAt);
        if (base) dates.push(base);

        if (!dates.length) return '';
        return dates.sort().pop();
    }

    function setDatePickerValue(dateStr) {
        const datePicker = document.getElementById('exchangeDatePicker');
        if (datePicker && dateStr) {
            datePicker.value = dateStr;
        }
    }

    function ensureSelectedDate() {
        const normalized = normalizeDate(selectedDate);
        if (normalized) return normalized;

        const latest = deriveLatestDateFromStats(latestStats);
        selectedDate = latest;
        setDatePickerValue(latest);
        return latest;
    }



    function formatBaseTime(baseTime) {
        if (!baseTime) return '-';

        const d = new Date(baseTime);
        if (isNaN(d.getTime())) return baseTime;

        const mm = String(d.getMonth() + 1).padStart(2, '0');
        const dd = String(d.getDate()).padStart(2, '0');
        const hh = String(d.getHours()).padStart(2, '0');
        const mi = String(d.getMinutes()).padStart(2, '0');
        const ss = String(d.getSeconds()).padStart(2, '0');

        return `${mm}.${dd} ${hh}:${mi}:${ss}`;
    }

    function updateBaseTimeText(baseTime) {
        document.querySelectorAll('.exchange-base-time').forEach((el) => {
            el.textContent = `(${formatBaseTime(baseTime)} 기준)`;
        });
    }


    function formatRangeOrDate(label) {
        if (!label) return '';
        return label.includes('~') ? label : formatDateLabel(label);
    }


    /* -----------------------------------------------------------------------
       ✔ 필터 UI 구성 (7개 통화만 출력)
    ----------------------------------------------------------------------- */
    function buildCurrencyFilter(currencies) {
        const filterEl = document.getElementById('currencyFilter');
        if (!filterEl) return;

        filterEl.innerHTML = '';

        currencies.forEach((code, idx) => {
            const label = document.createElement('label');
            label.className = 'admin-exchange-filter-item';

            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.value = code;

            // 기본 선택 처리
            checkbox.checked =
                selectedCurrencies.has(code) || (selectedCurrencies.size === 0 && code === 'USD');

            checkbox.addEventListener('change', () => {
                if (checkbox.checked) {
                    selectedCurrencies.add(code);
                } else {
                    selectedCurrencies.delete(code);
                    if (selectedCurrencies.size === 0) selectedCurrencies.add('USD');
                }
                renderCurrencyChart();
            });

            const text = document.createElement('span');
            text.textContent = code;

            label.appendChild(checkbox);
            label.appendChild(text);

            filterEl.appendChild(label);

            if (idx < currencies.length - 1) {
                const divider = document.createElement('span');
                divider.textContent = '|';
                divider.className = 'admin-exchange-filter-spacer';
                filterEl.appendChild(divider);
            }
        });
    }


    /* -----------------------------------------------------------------------
       ✔ 통화별 그래프 데이터 준비 (따옴표/중복 제거 포함)
    ----------------------------------------------------------------------- */
    function prepareCurrencyChartData() {

        const currencyData = Array.isArray(latestStats.currencyDailyAmounts)
            ? latestStats.currencyDailyAmounts
            : [];

        const useRange = rangeMode && rangeStartDate && rangeEndDate;
        const targetLabel = useRange
            ? (rangeLabel || `${rangeStartDate} ~ ${rangeEndDate}`)
            : ensureSelectedDate();

        const workingData = useRange
            ? currencyData
            : currencyData.filter(item => normalizeDate(item.baseDate) === targetLabel);
        const currencies = [...defaultCurrencies];


        buildCurrencyFilter(currencies);


        const activeCurrencies = currencies.filter(c => selectedCurrencies.has(c));

        const labels = activeCurrencies;
        const values = activeCurrencies.map((code) => {
            const found = workingData.find(item => cleanCurrency(item.currency) === code);            return found ? Number(found.amountKrw) : 0;


        });

        const maxVal = values.length > 0 ? Math.max(...values) : 0;

        const datasets = [{
            label: "",
            data: values,
            backgroundColor: activeCurrencies.map((_, idx) => pastelPalette[idx % pastelPalette.length]),
            borderRadius: 6,
            maxBarThickness: 44
        }];

        return { labels, datasets, targetLabel };





    }


    /* -----------------------------------------------------------------------
       ✔ 통화별 stacked bar 그래프 렌더링
    ----------------------------------------------------------------------- */
    function renderCurrencyChart() {
        const canvas = document.getElementById('currencyDailyChart');
        if (!canvas || typeof Chart === 'undefined') return;

        const { labels, datasets, targetLabel, maxVal } = prepareCurrencyChartData();

        if (!currencyChart) {
            currencyChart = new Chart(canvas.getContext('2d'), {
                type: 'bar',
                data: { labels, datasets },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                title: () => formatRangeOrDate(targetLabel),
                                label: (ctx) =>
                                    `${ctx.label}: ${ctx.parsed.y.toLocaleString('ko-KR')}원`
                            }
                        }
                    },
                    scales: {
                        x: { offset: true },
                        y: {
                            beginAtZero: true,
                            suggestedMax: maxVal === 0 ? 1 : maxVal * 1.1,
                            ticks: { callback: v => `${compactNumber(v)}원` }
                        }
                    }
                }
            });
        } else {
            currencyChart.data.labels = labels;
            currencyChart.data.datasets = datasets;
            currencyChart.options.scales.y.suggestedMax =
                maxVal === 0 ? 1 : maxVal * 1.1;
            currencyChart.update();
        }
    }


    /* -----------------------------------------------------------------------
       ✔ 일자별 총 환전액 그래프 렌더링
    ----------------------------------------------------------------------- */
    function renderTotalChart() {
        const canvas = document.getElementById('dailyTotalChart');
        if (!canvas || typeof Chart === 'undefined') return;

        // 최근 7일(오늘 포함), 미래 데이터는 제외
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        let totalData = Array.isArray(latestStats.dailyTotals)
            ? latestStats.dailyTotals
            : [];

        totalData = totalData
            .map(item => {
                const parsedDate = new Date(`${item.baseDate}T00:00:00`);
                return { ...item, parsedDate };
            })
            .filter(item => !isNaN(item.parsedDate) && item.parsedDate <= today)
            .sort((a, b) => a.parsedDate - b.parsedDate)
            .slice(-7);

        const labels = totalData.map(item => formatDateLabel(item.baseDate));
        const values = totalData.map(item => Number(item.amountKrw));

        const chartData = {
            labels,
            datasets: [{
                data: values,
                backgroundColor: 'rgba(79, 141, 231, 0.6)',
                borderRadius: 6,
                maxBarThickness: 40

            }]
        };

        if (!totalChart) {
            totalChart = new Chart(canvas.getContext('2d'), {
                type: 'bar',
                data: chartData,
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    layout: { padding: 0 },
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                title: (items) =>
                                    totalData[items[0].dataIndex]?.baseDate,
                                label: (ctx) =>
                                    `${ctx.parsed.y.toLocaleString('ko-KR')}원`
                            }
                        }
                    },
                    scales: {
                        x: { offset: true },
                        y: {
                            beginAtZero: true,
                            ticks: { callback: v => `${compactNumber(v)}원` }
                        }
                    }
                }
            });
        } else {
            totalChart.data = chartData;
            totalChart.update();
        }
    }


    /* -----------------------------------------------------------------------
       전체 렌더링
    ----------------------------------------------------------------------- */
    function renderAll() {
        renderCurrencyChart();
        renderTotalChart();
        updateBaseTimeText(latestStats.lastUpdatedAt);
    }


    /* -----------------------------------------------------------------------
       5분마다 최신 통계 자동 갱신
    ----------------------------------------------------------------------- */
    async function fetchLatestStats() {
        try {
            const res = await fetch('/flobank/admin/exchange/stats', {
                headers: { 'Accept': 'application/json' }
            });
            const data = await res.json();

            if (rangeMode) {
                latestStats.dailyTotals = data.dailyTotals;
                latestStats.lastUpdatedAt = data.lastUpdatedAt;
                renderTotalChart();
                updateBaseTimeText(data.lastUpdatedAt);
                return;
            }

            latestStats = data;

            const normalized = normalizeDate(selectedDate);
            const hasSelected = normalized && (data.currencyDailyAmounts || []).some(item => normalizeDate(item.baseDate) === normalized);
            if (!hasSelected) {
                selectedDate = deriveLatestDateFromStats(data);
                setDatePickerValue(selectedDate);
            }
            renderAll();
        } catch (e) {
            console.error(e);
        }
    }


    /* -----------------------------------------------------------------------
       ✔ 날짜별 통계 조회
    ----------------------------------------------------------------------- */

    function clearRangeMode() {
        rangeMode = false;
        rangeStartDate = '';
        rangeEndDate = '';
        rangeLabel = '';
    }


    async function fetchDateStats(date) {
        try {
            clearRangeMode();

            const res = await fetch(`/flobank/admin/exchange/stats?date=${date}`, {
                headers: { 'Accept': 'application/json' }
            });
            const data = await res.json();

            const hasData = (Array.isArray(data.currencyDailyAmounts) && data.currencyDailyAmounts.length > 0);

            if (!hasData) {
                alert('선택한 날짜의 환전 거래가 없습니다.');
                setDatePickerValue(ensureSelectedDate());
                return;
            }

            // 오른쪽 그래프 데이터는 유지해야 함 → dailyTotals는 유지!
            latestStats.currencyDailyAmounts = data.currencyDailyAmounts;

            // 날짜 갱신
            selectedDate = normalizeDate(date) || deriveLatestDateFromStats(latestStats);
            setDatePickerValue(selectedDate);

            renderCurrencyChart();  // 왼쪽 그래프만 업데이트
            updateBaseTimeText(data.lastUpdatedAt);  // 기준 시각 변경
        } catch (e) {
            console.error(e);
        }
    }


    /* -----------------------------------------------------------------------
   ✔ 기간 통계 조회 (왼쪽 그래프 전용)
----------------------------------------------------------------------- */
    async function fetchRangeStats(startDate, endDate) {
        try {
            const res = await fetch(`/flobank/admin/exchange/stats/range?startDate=${startDate}&endDate=${endDate}`, {
                headers: { 'Accept': 'application/json' }
            });
            const data = await res.json();

            const hasData = (Array.isArray(data.currencyDailyAmounts) && data.currencyDailyAmounts.length > 0);

            if (!hasData) {
                alert('선택한 기간의 환전 거래가 없습니다.');
                return;
            }

            rangeMode = true;
            rangeStartDate = startDate;
            rangeEndDate = endDate;
            rangeLabel = data.rangeLabel || `${startDate} ~ ${endDate}`;

            latestStats.currencyDailyAmounts = data.currencyDailyAmounts;
            latestStats.lastUpdatedAt = data.lastUpdatedAt;

            renderCurrencyChart();  // 왼쪽 그래프만 업데이트
            updateBaseTimeText(data.lastUpdatedAt);  // 기준 시각 변경
        } catch (e) {
            console.error(e);
        }
    }


    /* -----------------------------------------------------------------------
       페이지 로드시 실행
    ----------------------------------------------------------------------- */
    document.addEventListener("DOMContentLoaded", () => {

        if (typeof Chart === 'undefined') return;

        const today = getToday();

        // 오늘 날짜로 datePicker 설정
        const datePicker = document.getElementById("exchangeDatePicker");
        if (datePicker) {
            datePicker.value = today;
            selectedDate = today;
        }

        // 가장 먼저 오늘 날짜 기준으로 데이터 가져오기
        fetchDateStats(today);

        // 그래프 렌더링
        renderAll();

        const startPicker = document.getElementById("exchangeStartDatePicker");
        const endPicker = document.getElementById("exchangeEndDatePicker");
        const applyRangeBtn = document.getElementById("exchangePeriodApply");
        const resetRangeBtn = document.getElementById("exchangePeriodReset");



        // 날짜 선택 이벤트
        if (datePicker) {
            datePicker.addEventListener("change", function () {
                const nextDate = normalizeDate(this.value);
                if (!nextDate) return;

                //  왼쪽 날짜 선택 → 오른쪽 기간 자동 초기화
                const startPicker = document.getElementById("exchangeStartDatePicker");
                const endPicker = document.getElementById("exchangeEndDatePicker");

                if (startPicker) startPicker.value = "";
                if (endPicker) endPicker.value = "";

                // 기간 모드도 종료
                rangeMode = false;

                fetchDateStats(nextDate);
            });
        }


        if (applyRangeBtn) {
            applyRangeBtn.addEventListener("click", () => {
                const startDate = normalizeDate(startPicker?.value);
                const endDate = normalizeDate(endPicker?.value);

                if (!startDate || !endDate) {
                    alert('시작일과 종료일을 모두 선택해주세요.');
                    return;
                }

                if (startDate > endDate) {
                    alert('시작일은 종료일보다 이후일 수 없습니다.');
                    return;
                }

                // 오른쪽 날짜 선택시 왼쪽 초기화
                const singleDateInput = document.getElementById("exchangeDatePicker");
                if (singleDateInput) {
                    singleDateInput.value = "";   // → placeholder 상태로 돌아감
                }

                fetchRangeStats(startDate, endDate);
            });
        }

        /*초기화 버튼 클릭시 동작*/
        if (resetRangeBtn) {
            resetRangeBtn.addEventListener("click", () => {

                // 1) 기간 모드 해제
                clearRangeMode();
                if (startPicker) startPicker.value = '';
                if (endPicker) endPicker.value = '';

                // 2) 날짜를 오늘로 리셋
                if (datePicker) {
                    datePicker.value = today;
                }
                selectedDate = today;

                // 3) 체크박스 선택 상태 → USD만 선택하도록 강제 리셋
                selectedCurrencies.clear();
                selectedCurrencies.add("USD");

                // 4) 필터 UI를 USD만 체크된 상태로 재생성
                buildCurrencyFilter(defaultCurrencies);

                // 5) 오늘 데이터 불러오기
                fetchDateStats(today);

                // 6) 그래프 다시 렌더링
                renderCurrencyChart();

                // 7) 토스트 메시지 있으면 표시
                if (typeof showToast === "function") {
                    showToast("초기화 완료");
                }
            });
        }




        // 5분 자동 갱신
        setInterval(fetchLatestStats, 5 * 60 * 1000);
    });


})();
