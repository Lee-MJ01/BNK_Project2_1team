/*******************************************
 *   날짜 관련 함수
 *******************************************/
// 오늘 날짜 yyyy-MM-dd
function getToday() {
    const today = new Date();
    const y = today.getFullYear();
    const m = String(today.getMonth() + 1).padStart(2, "0");
    const d = String(today.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
}

// yyyy-MM-dd 변환
function formatDate(date) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, "0");
    const d = String(date.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
}

// 전날 계산
function getPreviousDate(dateStr) {
    const d = new Date(dateStr);
    d.setDate(d.getDate() - 1);
    return formatDate(d);
}


/*******************************************
 *   API 호출 + fallback
 *******************************************/
async function fetchRateWithFallback() {
    let date = getToday();

    for (let i = 0; i < 5; i++) {
        const res = await fetch(`/flobank/rate/data?date=${date}`);
        const data = await res.json();

        // 데이터 정상 여부
        if (data && data.length > 0 && data[0].result === 1) {
            return { date, data };
        }

        // 데이터 없으면 전날로 이동
        date = getPreviousDate(date);
    }

    return null;
}


/*******************************************
 *   환율 계산 로직
 *******************************************/
let exchangeRates = [];

// 통화별 환율 획득
function getRate(currency, type) {
    // 1. KRW(원화)는 환율을 무조건 1로 설정
    if (currency === "KRW") return 1;

    const cur = exchangeRates.find(c =>
        c.cur_unit === currency || c.cur_unit.startsWith(currency)
    );

    // 해당 통화가 데이터에 없으면 NaN 반환
    if (!cur) return NaN;

    const toNum = (val) => {
        if (!val || val === "-" || val.trim() === "") return NaN;
        return parseFloat(val.replace(/,/g, ""));
    };

    let base = toNum(cur.deal_bas_r);
    let ttb = toNum(cur.ttb);  // 송금 받을 때
    let tts = toNum(cur.tts);  // 송금 보낼 때

    // [중요] JPY(100), IDR(100) 등 단위가 100인 통화 처리 (선택 사항이지만 필수적)
    // 대부분의 한국 수출입은행 API 포맷은 cur_unit이 "JPY(100)" 형태입니다.
    if (cur.cur_unit.includes("(100)")) {
        base = base / 100;
        ttb = ttb / 100;
        tts = tts / 100;
    }

    // 2. 값이 0이거나 NaN이면 매매기준율(base)로 대체하는 로직 강화
    // 기존 코드: !isNaN(tts) ? tts : base;
    // 문제점: tts가 0이어도 숫자이므로 0을 반환함 -> Infinity 발생

    switch (type) {
        case "매매기준율":
            return base;
        case "송금보낼때":
            // 0보다 커야만 유효한 환율로 인정, 아니면 base 사용
            return (tts > 0) ? tts : base;
        case "송금받을때":
            // 0보다 커야만 유효한 환율로 인정, 아니면 base 사용
            return (ttb > 0) ? ttb : base;
        default:
            return base;
    }
}

// 환율 계산
function calculate() {
    const from = document.getElementById("fromCurrency").value;
    const to = document.getElementById("toCurrency").value;
    const amount = parseFloat(document.getElementById("amount").value);
    const type = document.getElementById("rateStandard").value;

    if (!amount || amount <= 0) return;

    const fromRate = getRate(from, type);
    const toRate = getRate(to, type);

    if (isNaN(fromRate) || isNaN(toRate)) {
        document.getElementById("convertedValue").innerText = "-";
        return;
    }

    // 동일 통화
    if (from === to) {
        document.getElementById("convertedValue").innerText = amount.toLocaleString();
        document.querySelector(".unit").innerText = to;
        return;
    }

    const converted = amount * (fromRate / toRate);

    document.getElementById("convertedValue").innerText = converted.toFixed(2).toLocaleString();
    document.querySelector(".unit").innerText = to;
}


/*******************************************
 *   페이지 초기 로딩
 *******************************************/
document.addEventListener("DOMContentLoaded", async () => {

    const result = await fetchRateWithFallback();

    if (!result) {
        alert("환율 데이터를 불러올 수 없습니다.");
        return;
    }

    // 실제 API 조회 날짜
    const apiDate = result.date;
    exchangeRates = result.data;

    // 날짜 표시 (yyyy.MM.dd 변환)
    const dateText = apiDate.replace(/-/g, ".");
    const dateEl = document.getElementById("rate-date-text");
    if (dateEl) {
        dateEl.innerText = `${dateText} 기준 환율입니다.`;
    }

    // 초기 계산 실행
    calculate();
});


document.getElementById("fromCurrency").addEventListener("change", calculate);
document.getElementById("toCurrency").addEventListener("change", calculate);
document.getElementById("rateStandard").addEventListener("change", calculate);
document.getElementById("amount").addEventListener("input", calculate);

