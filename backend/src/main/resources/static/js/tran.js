/*
 * tran.js
 * 원화 계좌이체 Step 1, Step 2 공용 스크립트
 */

document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('transferForm');

    // 폼이 없으면 아무것도 하지 않음 (오류 방지)
    if (!form) return;

    // --- [페이지 구분 로직] ---
    // 비밀번호 입력창이 존재하면 Step 1 페이지로 판단
    const accountPwInput = document.getElementById('accountPw');

    if (accountPwInput) {
        // [Step 1] 이체 정보 입력 및 유효성 검사 로직 실행
        initStep1(form, accountPwInput);
    } else {
        // [Step 2] 이체 확인 및 전자서명 로직 실행
        // (Step 2는 비밀번호 입력창이 없고 transferForm만 존재함)
        initStep2(form);
    }
});


/**
 * [Step 1] 초기화 및 이벤트 바인딩
 */
function initStep1(form, accountPwInput) {
    // Step 1 전용 DOM 요소 가져오기
    const tranAmountInput = document.getElementById('tranAmount');      // 보여지는 입력창
    const hiddenTranAmount = document.getElementById('hiddenTranAmount'); // 전송용 Hidden
    const tranRecAcctNoInput = document.getElementById('tranRecAcctNo');
    const tranRecBkCodeInput = document.getElementById('tranRecBkCode');
    const accountBalanceInput = document.getElementById('accountBalance');
    const tranAcctNoHidden = document.getElementById('tranAcctNo');

    // 에러 메시지 요소
    const tranAmountError = document.getElementById('tranAmountError');
    const tranRecAcctNoError = document.getElementById('tranRecAcctNoError');
    const accountPwError = document.getElementById('accountPwError');

    // 1. 금액 입력 이벤트 (콤마 처리 및 에러 리셋)
    if (tranAmountInput) {
        tranAmountInput.addEventListener('input', function() {
            inputNumberFormat(this); // 하단 유틸 함수 사용
            const currentVal = Number(uncomma(this.value));
            if (currentVal > 0) resetError(this, tranAmountError);
        });
    }

    // 2. 계좌번호 입력 이벤트 (에러 리셋)
    if (tranRecAcctNoInput) {
        tranRecAcctNoInput.addEventListener('input', function() {
            if (this.value.trim()) resetError(this, tranRecAcctNoError);
        });
    }

    // 3. 폼 제출(다음 버튼) 이벤트
    form.addEventListener('submit', async function(event) {
        event.preventDefault(); // 자동 제출 방지

        let isValid = true;
        const balance = accountBalanceInput ? Number(accountBalanceInput.value) : 0;
        const rawAmountStr = uncomma(tranAmountInput.value);
        const inputAmount = Number(rawAmountStr);

        // Hidden 필드 값 동기화
        if (hiddenTranAmount) hiddenTranAmount.value = rawAmountStr;

        // 에러 초기화
        resetError(tranAmountInput, tranAmountError);
        resetError(tranRecAcctNoInput, tranRecAcctNoError);
        resetError(accountPwInput, accountPwError);

        // --- [클라이언트 유효성 검사] ---
        if (!rawAmountStr || inputAmount <= 0) {
            showError(tranAmountInput, tranAmountError, "이체하실 금액을 입력해주세요.");
            isValid = false;
        } else if (inputAmount > balance) {
            showError(tranAmountInput, tranAmountError, "이체 금액이 잔액을 초과할 수 없습니다.");
            isValid = false;
        }

        if (!tranRecAcctNoInput.value.trim()) {
            showError(tranRecAcctNoInput, tranRecAcctNoError, "입금받으실 계좌번호를 입력해주세요.");
            if (isValid) tranRecAcctNoInput.focus();
            isValid = false;
        }

        if (!isValid) return false;

        // --- [서버 검증 (비밀번호 & 계좌실명)] ---
        const bankCode = tranRecBkCodeInput.value;
        const acctNo = tranRecAcctNoInput.value;

        try {
            const csrfTokenMeta = document.querySelector('meta[name="_csrf"]');
            const csrfHeaderMeta = document.querySelector('meta[name="_csrf_header"]');
            const headers = { 'Content-Type': 'application/json' };
            if (csrfTokenMeta && csrfHeaderMeta) {
                headers[csrfHeaderMeta.content] = csrfTokenMeta.content;
            }

            // (1) 비밀번호 확인
            const pwResponse = await fetch('/flobank/mypage/checkAcctPw', {
                method: 'POST',
                headers: headers,
                body: JSON.stringify({
                    acctNo: tranAcctNoHidden.value,
                    accountPw: accountPwInput.value
                })
            });

            if (!pwResponse.ok) throw new Error('비밀번호 통신 오류');
            const pwResult = await pwResponse.json();

            if (!pwResult.isPwCorrect) {
                showError(accountPwInput, accountPwError, "비밀번호가 일치하지 않습니다.");
                accountPwInput.focus();
                return;
            }

            // (2) 수취인 계좌 실명 확인
            const response = await fetch('/flobank/mypage/api/validate-account', {
                method: 'POST',
                headers: headers,
                body: JSON.stringify({ bankCode: bankCode, acctNo: acctNo })
            });

            if (!response.ok) throw new Error('계좌확인 통신 오류');
            const result = await response.json();

            if (result.exists) {
                // 검증 성공 시 Step 2로 이동 (Submit)
                // *주의: Step 1에서는 전자서명을 하지 않음
                form.submit();
            } else {
                showError(tranRecAcctNoInput, tranRecAcctNoError, "존재하지 않는 계좌번호입니다.");
                tranRecAcctNoInput.focus();
            }

        } catch (error) {
            console.error('Error:', error);
            alert("처리 중 문제가 발생했습니다.");
        }
    });
}


/**
 * [Step 2] 초기화 및 이벤트 바인딩
 */
function initStep2(form) {
    const hiddenTranAmount = document.getElementById('hiddenTranAmount');

    form.addEventListener('submit', function(event) {
        event.preventDefault(); // 바로 제출 막기

        // 금액 가져오기 (콤마 포맷팅해서 보여주기 위해)
        let displayAmount = '0';
        if (hiddenTranAmount) {
            displayAmount = Number(hiddenTranAmount.value).toLocaleString();
        }

        // 전자서명 호출
        if (typeof CertManager !== 'undefined') {
            CertManager.request(
                "계좌이체",   // 제목
                displayAmount, // 금액
                function() {
                    // [콜백] 인증 성공 시 폼 제출 -> Step 3 이동
                    form.submit();
                }
            );
        } else {
            alert("인증 모듈(CertManager)을 찾을 수 없습니다.");
        }
    });
}


// --- [전역 유틸리티 함수] (HTML onclick 속성에서 사용하기 위해 window 객체에 할당 권장 또는 전역 스코프 유지) ---

function comma(str) {
    str = String(str);
    return str.replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,');
}

function uncomma(str) {
    str = String(str);
    return str.replace(/[^\d]+/g, '');
}

function inputNumberFormat(obj) {
    obj.value = comma(uncomma(obj.value));
    const hiddenInput = document.getElementById('hiddenTranAmount');
    if (hiddenInput) {
        hiddenInput.value = uncomma(obj.value);
    }
}

// 금액 더하기 버튼 함수
function addAmount(amount) {
    const input = document.getElementById('tranAmount');
    const errorDiv = document.getElementById('tranAmountError');
    const accountBalanceInput = document.getElementById('accountBalance');

    // Step 2에서는 이 함수가 불릴 일이 없지만 안전장치
    if (!input) return;

    let currentVal = Number(uncomma(input.value)) || 0;
    let balance = accountBalanceInput ? Number(accountBalanceInput.value) : 0;
    let newVal = currentVal + amount;

    if (newVal > balance) {
        // showError 함수를 여기서 쓰려면 전역 혹은 이 스코프 내에 있어야 함
        // 여기서는 간단히 처리하거나 아래 showError를 전역으로 빼야 함
        if(errorDiv) {
            input.classList.add('input-error');
            errorDiv.textContent = "이체 금액이 잔액을 초과할 수 없습니다.";
            errorDiv.style.display = 'block';
        }
        input.focus();
        return;
    }

    input.value = comma(newVal);
    const hiddenInput = document.getElementById('hiddenTranAmount');
    if (hiddenInput) hiddenInput.value = newVal;

    input.classList.remove('input-error');
    if (errorDiv) errorDiv.style.display = 'none';
}

// 전액 버튼 함수
function setFullAmount(balance) {
    const input = document.getElementById('tranAmount');
    const errorDiv = document.getElementById('tranAmountError');

    if (!input) return;

    input.value = comma(balance);
    const hiddenInput = document.getElementById('hiddenTranAmount');
    if (hiddenInput) hiddenInput.value = balance;

    input.classList.remove('input-error');
    if (errorDiv) errorDiv.style.display = 'none';
}

// [헬퍼] 에러 표시
function showError(inputElement, errorElement, message) {
    if (inputElement) inputElement.classList.add('input-error');
    if (errorElement) {
        errorElement.textContent = message;
        errorElement.style.display = 'block';
    }
}

// [헬퍼] 에러 초기화
function resetError(inputElement, errorElement) {
    if (inputElement) inputElement.classList.remove('input-error');
    if (errorElement) errorElement.style.display = 'none';
}