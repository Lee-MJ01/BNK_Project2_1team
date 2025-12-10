/*
* 날짜 : 2025/11/20
* 이름 : 김대현
* 내용 : 약관 동의관련 수정
* */


////////////////////////////////////////////////////////////////////////////
// mypage.js — 통합버전 (금액 버튼 기능 추가됨)
////////////////////////////////////////////////////////////////////////////
let isPhoneVerified = false; // 'ko'와 'en'이 공용으로 사용할 전역 변수
let currentExchangeRate = 0; // 전역 변수로 환율 관리 (폼 전송 시 사용)

document.addEventListener("DOMContentLoaded", () => {

    ////////////////////////////////////////////////////////////////////////////
    // 1️⃣ 약관 동의(원화/외화 공통) - 전체동작
    ////////////////////////////////////////////////////////////////////////////
    const agreeAll = document.getElementById("agreeAll");
    const checks = document.querySelectorAll(".term-check");
    const termsForm = document.getElementById("termsForm");

    if (termsForm && agreeAll && checks.length > 0) {

        // 전체 동의 체크 시 개별 체크박스 모두 변경
        agreeAll.addEventListener("change", () => {
            checks.forEach(c => (c.checked = agreeAll.checked));
        });

        // 개별 체크 변경 시 전체동의 체크 여부 변경
        checks.forEach(chk => {
            chk.addEventListener("change", () => {
                agreeAll.checked = [...checks].every(c => c.checked);
            });
        });

        // 제출 시 전체 체크 여부 검사
        termsForm.addEventListener("submit", (e) => {
            const allChecked = [...checks].every(c => c.checked);

            if (!allChecked) {
                e.preventDefault();
                alert("모든 약관에 동의해야 다음 단계로 진행할 수 있습니다.");
            }
        });
    }



    ////////////////////////////////////////////////////////////////////////////
    // 3️⃣ 원화 계좌 한도 설정 (원화 페이지 전용)
    ////////////////////////////////////////////////////////////////////////////
    const dayLimitBtn = document.querySelectorAll(".open2-btn-limit")[0];
    const onceLimitBtn = document.querySelectorAll(".open2-btn-limit")[1];
    const dayLimitInput = document.querySelectorAll(".open2-limit-input")[0];
    const onceLimitInput = document.querySelectorAll(".open2-limit-input")[1];

    if (dayLimitBtn && onceLimitBtn && !document.getElementById("currency-select")) {
        dayLimitBtn.addEventListener("click", () => {
            dayLimitInput.value = "500,000,000";
        });

        onceLimitBtn.addEventListener("click", () => {
            onceLimitInput.value = "100,000,000";
        });
    }

    ////////////////////////////////////////////////////////////////////////////
    // 4️⃣ 외화 계좌 한도 설정 (외화 페이지 전용)
    ////////////////////////////////////////////////////////////////////////////
    const currencySelect = document.getElementById("currency-select");
    const dailyLimit = document.getElementById("daily-limit");
    const onceLimit = document.getElementById("once-limit");
    const currencyLabels = document.querySelectorAll(".currency-label");
    const guideTexts = document.querySelectorAll(".open2-guide-text");

    if (currencySelect && dailyLimit && onceLimit) {
        const usdLimits = { daily: "50,000", once: "10,000", min: "100" };

        const applyUsdLimits = () => {
            dailyLimit.value = usdLimits.daily;
            onceLimit.value = usdLimits.once;
            currencyLabels.forEach(label => (label.textContent = "USD"));
        };

        applyUsdLimits();
        currencySelect.addEventListener("change", () => {
            applyUsdLimits();
        });
    }

    ////////////////////////////////////////////////////////////////////////////
    // 5️⃣ '계좌 개설 2단계' (원화/외화) 공용 휴대폰 인증
    ////////////////////////////////////////////////////////////////////////////
    const btnSendSms_Acct = document.querySelector('.js-btn-send-code');
    const btnVerifySms_Acct = document.querySelector('.js-btn-verify-code');
    const inputSmsCode_Acct = document.querySelector('.js-verify-code-input');
    const mainContainer = document.querySelector('.open2-account-container[data-phone-number]');

    if (btnSendSms_Acct && btnVerifySms_Acct && inputSmsCode_Acct && mainContainer) {
        const unmaskedPhoneNumber = mainContainer.dataset.phoneNumber;

        if (!unmaskedPhoneNumber) {
            console.error("휴대폰 번호를 찾을 수 없습니다.");
            alert("오류: 고객 정보를 불러오지 못했습니다. 다시 시도해주세요.");
            return;
        }

        btnSendSms_Acct.addEventListener('click', async function (e) {
            e.preventDefault();
            btnSendSms_Acct.disabled = true;
            btnSendSms_Acct.textContent = '전송중...';

            try {
                const response = await fetch(`/flobank/sms/send?phoneNumber=${encodeURIComponent(unmaskedPhoneNumber)}`, { method: 'POST' });
                if (!response.ok) { throw new Error('SMS 전송 실패'); }
                alert('인증번호가 전송되었습니다.');

                inputSmsCode_Acct.style.display = 'inline-block';
                btnVerifySms_Acct.style.display = 'inline-block';
                inputSmsCode_Acct.focus();
                btnSendSms_Acct.textContent = '재전송';
            } catch (err) {
                console.error('SMS Send Error:', err);
                alert(`SMS 전송 중 오류 발생: ${err.message}`);
            } finally {
                btnSendSms_Acct.disabled = false;
            }
        });

        btnVerifySms_Acct.addEventListener('click', async function (e) {
            e.preventDefault();
            const code = inputSmsCode_Acct.value.trim();
            if (!unmaskedPhoneNumber || !code) {
                alert('전화번호와 인증번호를 입력해주세요.');
                return;
            }

            try {
                const response = await fetch(`/flobank/sms/verify?phoneNumber=${encodeURIComponent(unmaskedPhoneNumber)}&code=${encodeURIComponent(code)}`, { method: 'POST' });
                const isValid = await response.json();

                if (isValid) {
                    alert('휴대폰 인증 완료!');
                    isPhoneVerified = true;
                    inputSmsCode_Acct.readOnly = true;
                    btnSendSms_Acct.disabled = true;
                    btnVerifySms_Acct.disabled = true;
                    btnVerifySms_Acct.textContent = '인증완료';
                } else {
                    alert('인증번호가 일치하지 않습니다.');
                    isPhoneVerified = false;
                }
            } catch (err) {
                console.error('SMS Verify Error:', err);
                alert('인증 확인 중 오류 발생');
                isPhoneVerified = false;
            }
        });
    }

    ////////////////////////////////////////////////////////////////////////////
    // 6️⃣ '원화 계좌 개설 2단계' - 계좌 비밀번호 일치 확인
    ////////////////////////////////////////////////////////////////////////////
    const acctPwInput = document.getElementById('acctPw');
    const acctPwConfirmInput = document.getElementById('acctPwConfirm');
    const pwMatchMsg = document.getElementById('pwMatchMessage');

    if (acctPwInput && acctPwConfirmInput && pwMatchMsg) {
        function checkKoAcctPasswordMatch() {
            const pw = acctPwInput.value;
            const confirmPw = acctPwConfirmInput.value;
            if (confirmPw === '') { pwMatchMsg.textContent = ''; return; }

            const numPattern = /^\d{4}$/;
            if (pw.length > 0 && !numPattern.test(pw)) {
                pwMatchMsg.textContent = '비밀번호는 숫자 4자리여야 합니다.';
                pwMatchMsg.style.color = '#E53935';
                return;
            }

            if (pw === confirmPw) {
                pwMatchMsg.textContent = '비밀번호가 일치합니다.';
                pwMatchMsg.style.color = '#4A6FA5';
            } else {
                pwMatchMsg.textContent = '비밀번호가 일치하지 않습니다.';
                pwMatchMsg.style.color = '#E53935';
            }
        }
        acctPwInput.addEventListener('input', checkKoAcctPasswordMatch);
        acctPwConfirmInput.addEventListener('input', checkKoAcctPasswordMatch);
    }

    ////////////////////////////////////////////////////////////////////////////
    // 7️⃣ '원화 계좌 개설 2단계' - 폼 제출 유효성 검사
    ////////////////////////////////////////////////////////////////////////////
    const koAccountForm = document.getElementById('koAccountOpenForm');
    if (koAccountForm) {
        koAccountForm.addEventListener('submit', function(e) {
            const purposeSelect = document.getElementById('cddPurpose');
            const sourceSelect = document.getElementById('cddSource');
            const pw = acctPwInput ? acctPwInput.value : "";
            const pwConfirm = acctPwConfirmInput ? acctPwConfirmInput.value : "";

            if (isPhoneVerified === false) {
                e.preventDefault();
                alert('휴대폰 인증을 완료해주세요.');
                document.querySelector('.open2-verify-section').scrollIntoView({ behavior: 'smooth' });
                return;
            }
            if (purposeSelect && purposeSelect.value === "") {
                e.preventDefault();
                alert('거래 목적을 선택해주세요.');
                purposeSelect.focus();
                return;
            }
            if (sourceSelect && sourceSelect.value === "") {
                e.preventDefault();
                alert('자금 출처를 선택해주세요.');
                sourceSelect.focus();
                return;
            }
            if (pw.length < 4 || !/^\d{4}$/.test(pw)) {
                e.preventDefault();
                alert('계좌 비밀번호 4자리를 정확히 입력해주세요.');
                if(acctPwInput) acctPwInput.focus();
                return;
            }
            if (pw !== pwConfirm) {
                e.preventDefault();
                alert('계좌 비밀번호가 일치하지 않습니다.');
                if(acctPwConfirmInput) acctPwConfirmInput.focus();
                return;
            }
        });
    }

    ////////////////////////////////////////////////////////////////////////////
    // 8️⃣ '외화 계좌 개설 2단계' - 계좌 비밀번호 일치 확인
    ////////////////////////////////////////////////////////////////////////////
    const enAcctPwInput = document.getElementById('enAcctPw');
    const enAcctPwConfirmInput = document.getElementById('enAcctPwConfirm');
    const enPwMatchMsg = document.getElementById('enPwMatchMessage');

    if (enAcctPwInput && enAcctPwConfirmInput && enPwMatchMsg) {
        function checkEnAcctPasswordMatch() {
            const pw = enAcctPwInput.value;
            const confirmPw = enAcctPwConfirmInput.value;
            if (confirmPw === '') { enPwMatchMsg.textContent = ''; return; }

            const numPattern = /^\d{4}$/;
            if (pw.length > 0 && !numPattern.test(pw)) {
                enPwMatchMsg.textContent = '비밀번호는 숫자 4자리여야 합니다.';
                enPwMatchMsg.style.color = '#E53935';
                return;
            }

            if (pw === confirmPw) {
                enPwMatchMsg.textContent = '비밀번호가 일치합니다.';
                enPwMatchMsg.style.color = '#4A6FA5';
            } else {
                enPwMatchMsg.textContent = '비밀번호가 일치하지 않습니다.';
                enPwMatchMsg.style.color = '#E53935';
            }
        }
        enAcctPwInput.addEventListener('input', checkEnAcctPasswordMatch);
        enAcctPwConfirmInput.addEventListener('input', checkEnAcctPasswordMatch);
    }

    ////////////////////////////////////////////////////////////////////////////
    // 9️⃣ '외화 계좌 개설 2단계' - 폼 제출 유효성 검사
    ////////////////////////////////////////////////////////////////////////////
    const enAccountForm = document.getElementById('enAccountOpenForm');
    if (enAccountForm) {
        enAccountForm.addEventListener('submit', function(e) {
            const pw = enAcctPwInput ? enAcctPwInput.value : "";
            const pwConfirm = enAcctPwConfirmInput ? enAcctPwConfirmInput.value : "";
            const purposeSelect_en = document.getElementById('cddPurpose');
            const sourceSelect_en = document.getElementById('cddSource');

            if (isPhoneVerified === false) {
                e.preventDefault();
                alert('휴대폰 인증을 완료해주세요.');
                document.querySelector('.open2-verify-section').scrollIntoView({ behavior: 'smooth' });
                return;
            }
            if (purposeSelect_en && purposeSelect_en.value === "") {
                e.preventDefault();
                alert('거래 목적을 선택해주세요.');
                purposeSelect_en.focus();
                return;
            }
            if (sourceSelect_en && sourceSelect_en.value === "") {
                e.preventDefault();
                alert('자금 출처를 선택해주세요.');
                sourceSelect_en.focus();
                return;
            }
            if (pw.length < 4 || !/^\d{4}$/.test(pw)) {
                e.preventDefault();
                alert('계좌 비밀번호 4자리를 정확히 입력해주세요.');
                if (enAcctPwInput) enAcctPwInput.focus();
                return;
            }
            if (pw !== pwConfirm) {
                e.preventDefault();
                alert('계좌 비밀번호가 일치하지 않습니다.');
                if (enAcctPwConfirmInput) enAcctPwConfirmInput.focus();
                return;
            }
        });
    }

    ////////////////////////////////////////////////////////////////////////////
    // 🔟 [최종 수정] 실시간 환율 계산, 한도 체크, 원화 환산, 금액 버튼
    ////////////////////////////////////////////////////////////////////////////
    const accountSelect = document.getElementById('account-select');
    const transferCurrencySelect = document.getElementById('transfer-currency-select');
    const amountInput = document.getElementById('transferable-amount'); // 송금 가능 금액 (readonly)
    const currencyUnit = document.getElementById('currency-unit');
    const userTransferInput = document.getElementById('transfer-amount'); // 사용자가 입력하는 곳
    const limitWarning = document.getElementById('limit-warning');        // 경고 메시지
    const krwEquivalentSpan = document.getElementById('krw-equivalent');  // 원화 환산 텍스트

    // 송금 페이지 요소가 모두 있을 때만 실행
    if (accountSelect && transferCurrencySelect && amountInput && currencyUnit && userTransferInput) {

        const today = "20251114"; // 테스트용 날짜 (운영 시 로직 변경 필요)

        // 1. 환율 정보 가져오기 및 초기화 함수
        function updateTransferableAmount() {
            const selectedOption = accountSelect.options[accountSelect.selectedIndex];
            const accountType = selectedOption.getAttribute('data-type');
            const targetCurrency = transferCurrencySelect.value;

            // 단위 표시 업데이트
            currencyUnit.textContent = targetCurrency;

            // 외화 계좌(FRGN)라면 잔액을 미리 세팅
            if (accountType === 'FRGN') {
                const balanceAttr = selectedOption.getAttribute(`data-balance-${targetCurrency.toLowerCase()}`);
                const frgnBalance = balanceAttr ? parseFloat(balanceAttr) : 0;
                amountInput.value = frgnBalance.toLocaleString(undefined, {minimumFractionDigits: 2});
            }

            // 환율 API 호출
            fetch(`/flobank/rate/data?date=${today}`)
                .then(response => response.json())
                .then(data => {
                    const rateInfo = data.find(item => {
                        if (targetCurrency === 'JPY' || targetCurrency === 'IDR') {
                            return item.cur_unit.startsWith(targetCurrency);
                        }
                        return item.cur_unit === targetCurrency;
                    });

                    if (rateInfo) {
                        let rate = parseFloat(rateInfo.deal_bas_r.replace(/,/g, ''));
                        if (rateInfo.cur_unit.includes('(100)')) {
                            rate = rate / 100;
                        }

                        currentExchangeRate = rate; // 전역 변수 저장

                        // 원화 계좌(KRW) 계산
                        if (accountType === 'KRW') {
                            const balanceAttr = selectedOption.getAttribute('data-balance');
                            const balance = balanceAttr ? parseFloat(balanceAttr) : 0;
                            const transferable = Math.floor((balance / rate) * 100) / 100;
                            amountInput.value = transferable.toLocaleString(undefined, {minimumFractionDigits: 2});
                        }
                        updateKrwPreview();
                    } else {
                        amountInput.value = "환율 정보 없음";
                        currentExchangeRate = 0;
                        krwEquivalentSpan.textContent = "환율 정보가 없어 계산할 수 없습니다.";
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    amountInput.value = "오류 발생";
                });
        }

        // 2. 사용자 입력 시 이벤트 (한도체크, 원화환산)
        userTransferInput.addEventListener('input', function() {
            const inputVal = parseFloat(this.value.replace(/,/g, '')) || 0;
            const maxVal = parseFloat(amountInput.value.replace(/,/g, '')) || 0;

            if (inputVal > maxVal) {
                limitWarning.style.display = 'block';
                this.value = maxVal.toLocaleString(undefined, {minimumFractionDigits: 2});
            } else {
                limitWarning.style.display = 'none';
            }
            updateKrwPreview();
        });

        // [추가됨] 3. 금액 버튼 (100, 500... 전액) 클릭 이벤트 처리
        const amountBtns = document.querySelectorAll('.transfer1-btn-group button');
        amountBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const btnText = btn.textContent;
                // 현재 송금 가능 최대 금액
                const maxVal = parseFloat(amountInput.value.replace(/,/g, '')) || 0;
                // 현재 입력된 금액 (없으면 0)
                let currentVal = parseFloat(userTransferInput.value.replace(/,/g, '')) || 0;
                let newVal = 0;

                if (btnText === '전액') {
                    // 전액 버튼: 최대 한도로 설정
                    newVal = maxVal;
                } else {
                    // 숫자 버튼: 현재 값에 더하기 (누적)
                    newVal = currentVal + parseFloat(btnText);
                }

                // 한도 초과 시 최대값으로 고정
                if (newVal > maxVal) {
                    newVal = maxVal;
                }

                // 값 반영 (콤마 포맷 적용)
                userTransferInput.value = newVal.toLocaleString();

                // [중요] 값이 변경되었으므로 'input' 이벤트를 발생시켜 원화 환산 및 경고 로직 실행
                userTransferInput.dispatchEvent(new Event('input'));
            });
        });

        // 4. 원화 환산 표시 함수
        function updateKrwPreview() {
            const inputVal = parseFloat(userTransferInput.value.replace(/,/g, '')) || 0;
            if (currentExchangeRate > 0) {
                const krwVal = Math.floor(inputVal * currentExchangeRate);
                krwEquivalentSpan.textContent = `예상 원화 금액: 약 ${krwVal.toLocaleString()} 원`;
            } else {
                krwEquivalentSpan.textContent = "입력된 송금 금액을 원화로";
            }
        }

        // [추가 함수] 통화 변경 시 외화 계좌번호(Value) 업데이트
        function updateFrgnAccountNumber() {
            const selectedOption = accountSelect.options[accountSelect.selectedIndex];
            const accountType = selectedOption.getAttribute('data-type'); // FRGN or KRW

            // 외화 계좌(FRGN)가 선택된 상태일 때만 동작
            if (accountType === 'FRGN') {
                // 선택된 통화 (예: USD, JPY)
                const targetCurrency = transferCurrencySelect.value.toLowerCase();

                // HTML data 속성에서 해당 통화의 자식 계좌번호(balNo) 가져오기
                // 예: th:data-account-usd="..." 의 값을 읽음
                const childAcctNo = selectedOption.getAttribute(`data-account-${targetCurrency}`);

                if (childAcctNo) {
                    // ★ 핵심: 실제 전송될 option의 value를 자식 계좌번호로 변경
                    selectedOption.value = childAcctNo;
                    // (선택사항) 디버깅용 로그
                    // console.log(`송금 계좌번호 변경됨: ${childAcctNo} (${targetCurrency})`);
                }
            }
        }

        // 이벤트 리스너 등록
        accountSelect.addEventListener('change', () => {
            userTransferInput.value = '';
            limitWarning.style.display = 'none';

            updateFrgnAccountNumber(); // [추가] 계좌가 바뀌어도 현재 통화에 맞춰 계좌번호 세팅
            updateTransferableAmount();
        });
        transferCurrencySelect.addEventListener('change', () => {
            userTransferInput.value = '';
            limitWarning.style.display = 'none';

            updateFrgnAccountNumber(); // [추가] 계좌번호 먼저 업데이트
            updateTransferableAmount(); // 그 다음 잔액/환율 업데이트
        });

        // 초기 실행 시에도 적용
        updateFrgnAccountNumber();
        updateTransferableAmount();
    }

    ////////////////////////////////////////////////////////////////////////////
    // 1️⃣3️⃣ [추가] 외화 계좌이체 Step 3 - 전자서명 연동
    ////////////////////////////////////////////////////////////////////////////
    const btnTransfer = document.getElementById('btnTransfer');
    const transferForm = document.getElementById('transferForm');
    const hiddenRemtAmount = document.getElementById('hiddenRemtAmount');
    const hiddenRemtCurrency = document.getElementById('hiddenRemtCurrency');

    if (btnTransfer && transferForm) {
        btnTransfer.addEventListener('click', function() {
            // 1. 송금 정보 구성 (팝업에 보여줄 내용)
            let displayAmount = '0';
            let currency = 'USD'; // 기본값

            if (hiddenRemtAmount) {
                // 숫자 -> 3자리 콤마 포맷팅
                displayAmount = Number(hiddenRemtAmount.value).toLocaleString();
            }
            if (hiddenRemtCurrency) {
                currency = hiddenRemtCurrency.value;
            }

            const title = "해외송금 실행";
            const infoText = `${displayAmount} ${currency}`; // 예: 1,000 USD

            // 2. 전자서명 모듈 호출 (CertManager는 common_cert.js에 정의됨)
            if (typeof CertManager !== 'undefined') {
                CertManager.request(
                    title,      // 인증창 제목
                    infoText,   // 인증창 금액/내용
                    function() {
                        // 3. [콜백] 인증 성공 시 폼 제출
                        transferForm.submit();
                    }
                );
            } else {
                alert("인증 모듈(CertManager)이 로드되지 않았습니다.");
                // 개발 단계에서는 강제 제출 허용 가능: transferForm.submit();
            }
        });
    }

}); // DOMContentLoaded 끝

////////////////////////////////////////////////////////////////////////////
// 1️⃣1️⃣ 공통 유틸 함수 (전역 스코프)
////////////////////////////////////////////////////////////////////////////

function setQuestion(text) {
    const chatInput = document.getElementById('chatInput');
    if(chatInput) chatInput.value = text;
}

// 폼 전송 전 데이터 정제 및 필수 입력값 검증 함수
async function submitTransferForm() {
    const form = document.getElementById('transferForm');
    if (!form) return;

    // ==========================================
    // 1. 유효성 검사 (Validation) - 먼저 실행!
    // ==========================================

    // 송금 금액 확인
    const visibleAmount = document.getElementById('transfer-amount');
    const cleanAmount = visibleAmount.value.replace(/,/g, '');
    if (!cleanAmount || isNaN(cleanAmount) || parseFloat(cleanAmount) <= 0) {
        alert("송금할 금액을 입력해주세요.");
        visibleAmount.focus();
        visibleAmount.scrollIntoView({behavior: 'smooth', block: 'center'});
        return;
    }

    // [수정됨] 비밀번호 입력 확인 (HTML에 id="input-account-pw"가 있어야 동작함)
    const pwInput = document.getElementById('input-account-pw');
    if (!pwInput || pwInput.value.trim().length !== 4) {
        alert("계좌 비밀번호 4자리를 입력해주세요.");
        if (pwInput) pwInput.focus();
        return;
    }

    // 수취인 이름 확인
    const recName = document.querySelector('input[name="remtRecName"]');
    if (recName && !recName.value.trim()) {
        alert("수취인 성명(영문)을 입력해주세요.");
        recName.focus();
        recName.scrollIntoView({behavior: 'smooth', block: 'center'});
        return;
    }

    // 은행 코드 확인
    const recBkCode = document.querySelector('input[name="remtRecBkCode"]');
    if (recBkCode && !recBkCode.value.trim()) {
        alert("은행 코드를 입력해주세요.");
        recBkCode.focus();
        recBkCode.scrollIntoView({behavior: 'smooth', block: 'center'});
        return;
    }

    // 계좌번호 확인
    const recAccNo = document.querySelector('input[name="remtRecAccNo"]');
    if (recAccNo && !recAccNo.value.trim()) {
        alert("수취인 계좌번호를 입력해주세요.");
        recAccNo.focus();
        recAccNo.scrollIntoView({behavior: 'smooth', block: 'center'});
        return;
    }

    // ==========================================
    // 2. 서버 비밀번호 검증 (AJAX Fetch)
    // ==========================================
    const accountSelect = document.getElementById('account-select');
    // 선택된 옵션에서 모체 계좌번호 가져오기
    const selectedOption = accountSelect.options[accountSelect.selectedIndex];
    // 계좌 타입(data-type) 가져오기 (FRGN 또는 KRW)
    const accountType = selectedOption.getAttribute('data-type');

    // 선택된 옵션에서 모체 계좌번호 가져오기
    const parentAcctNoAttr = selectedOption.getAttribute('data-parent-acct-no');

    // data-parent-acct-no가 있으면(외화계좌) 그 값을 사용, 없으면(원화계좌) value 사용
    const selectedAcctNo = parentAcctNoAttr ? parentAcctNoAttr : accountSelect.value;
    const inputPw = pwInput.value;              // 입력된 비밀번호

    try {
        const csrfTokenMeta = document.querySelector('meta[name="_csrf"]');
        const csrfHeaderMeta = document.querySelector('meta[name="_csrf_header"]');
        const headers = {'Content-Type': 'application/json'};

        if (csrfTokenMeta && csrfHeaderMeta) {
            headers[csrfHeaderMeta.content] = csrfTokenMeta.content;
        }

        const response = await fetch('/flobank/remit/checkEnAcctPw', {
            method: 'POST',
            headers: headers,
            body: JSON.stringify({
                acctNo: selectedAcctNo,
                acctPw: inputPw,
                acctType: accountType
            })
        });

        if (!response.ok) {
            throw new Error('서버 통신 오류가 발생했습니다.');
        }

        const result = await response.json();

        if (!result.isPwCorrect) {
            alert("비밀번호가 일치하지 않습니다.");
            pwInput.value = '';
            pwInput.focus();
            return;
        }

        // ==========================================
        // 3. 데이터 정제 및 폼 제출 (비밀번호 검증 통과 시)
        // ==========================================

        const hiddenAmountInput = document.getElementById('hidden-remt-amount');
        if (hiddenAmountInput) hiddenAmountInput.value = cleanAmount;

        const hiddenRateInput = document.getElementById('hidden-applied-rate');
        if (hiddenRateInput) {
            hiddenRateInput.value = (typeof currentExchangeRate !== 'undefined' && currentExchangeRate > 0)
                ? currentExchangeRate : 0;
        }

        const zipInput = document.getElementById('input-zip-code');
        const addrInput = document.querySelector('input[name="remtAddr"]');
        if (zipInput && addrInput && zipInput.value.trim() !== "") {
            if (!addrInput.value.startsWith('[')) {
                addrInput.value = `[${zipInput.value.trim()}] ${addrInput.value.trim()}`;
            }
        }

        form.submit();

    } catch (error) {
        console.error("Password Check Error:", error);
        alert("계좌 확인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.");
    }
}

////////////////////////////////////////////////////////////////////////////
// 1️⃣2️⃣ [수정됨] 국가별 라벨 단순 변경 (추가 필드 제거)
////////////////////////////////////////////////////////////////////////////

const countrySettings = {
    'USA': {
        bankLabel: '은행코드 (ACH Routing No)',
        bankPlace: '9자리 숫자',
        acctLabel: '계좌번호 (Account No)',
        acctPlace: '예: 1234567890'
    },
    'JPN': {
        bankLabel: 'SWIFT BIC',
        bankPlace: '영문+숫자 8~11자리',
        acctLabel: '계좌번호 (Account No)',
        acctPlace: '예: 1234567'
    },
    'DEU': { // 유럽
        bankLabel: 'SWIFT BIC',
        bankPlace: '영문+숫자 8~11자리',
        acctLabel: 'IBAN Code',
        acctPlace: '국가코드 포함 전체'
    },
    'CHN': {
        bankLabel: 'CNAPS Code',
        bankPlace: '12자리 숫자',
        acctLabel: '계좌번호 (Account No)',
        acctPlace: '예: 621483...'
    },
    'AUS': {
        bankLabel: 'BSB Code',
        bankPlace: '6자리 숫자',
        acctLabel: '계좌번호 (Account No)',
        acctPlace: '최대 9자리 숫자'
    },
    'GBR': {
        bankLabel: 'Sort Code',
        bankPlace: '6자리 숫자 (예: 20-00-00)',
        acctLabel: '계좌번호 (Account No)',
        acctPlace: '8자리 숫자'
    }
};

function updateReceiverForm() {
    const countrySelect = document.getElementById('country-select');
    if (!countrySelect) return;

    const selectedCountry = countrySelect.value;
    const settings = countrySettings[selectedCountry];

    if (settings) {
        document.getElementById('label-bank-code').textContent = settings.bankLabel;
        document.getElementById('input-bank-code').placeholder = settings.bankPlace;
        document.getElementById('label-account-no').textContent = settings.acctLabel;
        document.getElementById('input-account-no').placeholder = settings.acctPlace;
    }
}

document.addEventListener('DOMContentLoaded', () => {
    const countrySelect = document.getElementById('country-select');
    if(countrySelect) {
        countrySelect.addEventListener('change', updateReceiverForm);
        updateReceiverForm(); // 초기화
    }
});