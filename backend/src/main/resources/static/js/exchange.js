/*
* 날짜 : 2025/11/22
* 이름 : 김대현, 이민준
* 내용 : 환전 기능 (변수 중복 제거, 동적 data-flag 적용 완료)
*/

document.addEventListener("DOMContentLoaded", () => {

    // =========================================
    // 서버 데이터 수신 및 처리 로직 이동
    // =========================================
    const frgnBalanceMap = {};
    let frgnAcctNo = '';

    if (window.exchData) {
        // 1. 외화 계좌번호 가져오기
        frgnAcctNo = window.exchData.frgnAcctNo || '';

        // 2. 잔액 리스트를 Map으로 변환 { 'USD': 100.00, ... }
        const rawList = window.exchData.balanceList;
        if (rawList && Array.isArray(rawList)) {
            rawList.forEach(dto => {
                frgnBalanceMap[dto.balCurrency] = dto.balBalance;
            });
        }
    }

    // =========================================
    // 1. DOM 요소 선택 (중복 선언 통합 완료)
    // =========================================
    const fromCurrency = document.getElementById("fromCurrency");
    const toCurrency = document.getElementById("toCurrency");
    const fromAmount = document.getElementById("fromAmount");
    const toAmount = document.getElementById("toAmount");

    const receiveDateInput = document.getElementById("receiveDate");

    const fromFlag = document.getElementById("fromFlag"); // 국기 이미지 태그
    const toFlag = document.getElementById("toFlag");     // 국기 이미지 태그

    const accountWon = document.getElementById("accountSelectWon");
    const accountForeign = document.getElementById("accountSelectForeign");
    const withdrawLabel = document.getElementById("withdrawLabel");
    const pwInput = document.getElementById("pwInput");

    const buySection = document.getElementById("buySection");
    const sellSection = document.getElementById("sellSection");

    const resultBaseRate = document.getElementById("result-base-rate");
    const resultRate = document.getElementById("result-rate");
    // const resultFee = document.getElementById("result-fee");
    const resultFinal = document.getElementById("result-final");
    const spreadRateDisplay = document.getElementById("spreadRateDisplay");

    const couponBtn = document.getElementById("couponBtn");
    const couponModal = document.getElementById("couponModal");
    const couponClose = document.getElementById("couponClose");
    const couponOptions = document.querySelectorAll(".coupon-option");

    // [수정] 전역 변수 및 상수 정의
    let selectedCouponRate = 0; // 쿠폰 할인율 (예: 50% -> 0.5)
    let currentBaseRate = 0;    // 매매기준율
    let currentTtsRate = 0;     // 전신환매도율 (TTS)
    let currentTtbRate = 0;     // 전신환매입율 (받으실 때)
    let currentMode = 'BUY';

    // 1. 우리 플로은행의 기본 환율 수수료는 0.95 (95%)
    const BASE_FEE_RATE  = 0.95;

    // 통화별 기본 우대율 설정
    // 이미지에 있는 통화별 우대율을 매핑 (달러 70%, 엔/유로 50%, 그외 30%)
    const BASE_PREF_RATES = {
        'USD': 0.70,
        'JPY': 0.50,
        'EUR': 0.50,
        'CNY': 0.30,
        'CNH': 0.30,
        'GBP': 0.30,
        'AUD': 0.30,
        'OTHERS': 0.30
    };

    // =========================================
    // 2. 초기화 및 헬퍼 함수
    // =========================================

    // [핵심 함수] 선택된 옵션의 data-flag 값을 읽어서 이미지 변경
    function changeFlag(selectElement, imgElement) {
        if (!selectElement || !imgElement) return;

        // 현재 선택된 option 태그 찾기
        const selectedOption = selectElement.options[selectElement.selectedIndex];

        // option 태그에 심어둔 data-flag 값 가져오기
        if (selectedOption) {
            const flagPath = selectedOption.getAttribute('data-flag');
            // 이미지 경로 교체
            if (flagPath) {
                imgElement.src = flagPath;
            }
        }
    }

    // 휴대폰 번호 초기화
    const phoneInputs = document.querySelectorAll('.step2-input.small');
    if (phoneInputs.length >= 3) {
        phoneInputs[0].value = "010";
    }

    // ---------------------------------------------------------
    // 수령일(receiveDate) 과거 날짜 선택 방지
    // ---------------------------------------------------------
    if (receiveDateInput) {
        const today = new Date();
        const year = today.getFullYear();
        // 월과 일은 2자리(01, 02...)로 맞춰야 input type="date"가 인식함
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');

        const minDate = `${year}-${month}-${day}`; // 예: "2025-11-24"

        // min 속성에 오늘 날짜 할당 -> 오늘 이전 날짜는 선택 불가(회색 처리)됨
        receiveDateInput.setAttribute("min", minDate);

        // (선택사항) 기본값을 오늘로 설정하고 싶다면 아래 주석 해제
        // receiveDateInput.value = minDate;
    }

    // 초기 화면 설정
    updateUIState();

    // 초기 국기 설정 (HTML에 설정된 data-flag 기반)
    changeFlag(fromCurrency, fromFlag);
    changeFlag(toCurrency, toFlag);

    // 초기 환율 가져오기
    fetchRate(toCurrency.value);


    // =========================================
    // 3. 이벤트 리스너
    // =========================================

    // (1) 왼쪽(From) 통화 변경 시
    fromCurrency.addEventListener("change", () => {
        const val = fromCurrency.value;
        changeFlag(fromCurrency, fromFlag); // 국기 업데이트

        if (val === 'KRW') {
            // 원화 -> 외화 (BUY 모드)
            updateSelectOptions(toCurrency, 'FOREIGN');
        } else {
            // 외화 -> 원화 (SELL 모드)
            // 오른쪽을 KRW로 고정하면서 data-flag도 같이 넣어줘야 함
            toCurrency.innerHTML = '';
            const opt = document.createElement('option');
            opt.value = "KRW";
            opt.text = "KRW (대한민국 원)";
            opt.setAttribute("data-flag", "/flobank/images/krw.png"); // 이미지 경로 주의
            toCurrency.appendChild(opt);
        }

        // 오른쪽 국기도 업데이트 (옵션 내용이 바뀌었으므로)
        changeFlag(toCurrency, toFlag);

        updateUIState();

        const foreignCode = (val === 'KRW') ? toCurrency.value : val;
        fetchRate(foreignCode);
    });

    // (2) 오른쪽(To) 통화 변경 시
    toCurrency.addEventListener("change", () => {
        changeFlag(toCurrency, toFlag); // 국기 업데이트
        fetchRate(toCurrency.value);
    });

    // (3) 금액 입력 시 실시간 계산
    fromAmount.addEventListener("input", () => {
        calculateExchange();
    });

    // 쿠폰 선택 로직
    if (couponBtn) couponBtn.addEventListener("click", () => couponModal.style.display = "flex");
    if (couponClose) couponClose.addEventListener("click", () => couponModal.style.display = "none");
    couponOptions.forEach(btn => {
        btn.addEventListener("click", () => {
            // 버튼의 data-discount 값 (예: 0.5)
            selectedCouponRate = parseFloat(btn.dataset.discount);

            // 화면에 쿠폰 적용되었음을 알림 (옵션)
            if(couponBtn) couponBtn.innerText = `쿠폰적용(${(selectedCouponRate*100).toFixed(0)}%)`;

            alert("쿠폰이 적용되었습니다.");
            couponModal.style.display = "none";

            // 재계산 수행
            calculateExchange();
        });
    });


    // =========================================
    // 4. 기능 함수들
    // =========================================

    function updateUIState() {
        currentMode = (fromCurrency.value === 'KRW') ? 'BUY' : 'SELL';

        if (currentMode === 'BUY') {
            withdrawLabel.innerText = '출금계좌선택 (원화)';
            accountWon.style.display = 'block';
            accountForeign.style.display = 'none';
            buySection.style.display = 'block';
            sellSection.style.display = 'none';
        } else {
            withdrawLabel.innerText = '출금계좌선택 (외화)';
            accountWon.style.display = 'none';
            accountForeign.style.display = 'block';
            buySection.style.display = 'none';
            sellSection.style.display = 'block';
            // SELL 모드일 때, 선택된 외화에 맞는 잔액 표시
            updateForeignAcctBalanceDisplay();
        }

        calculateExchange();
    }

    // [로직 이동 완료] 외화 계좌 잔액 표시 함수
    function updateForeignAcctBalanceDisplay() {
        if (!accountForeign || accountForeign.options.length === 0) return;

        // 현재 선택된 '보내는 통화' (예: USD)
        const targetCurrency = fromCurrency.value;

        // JS 내부 Map에서 조회
        const balance = frgnBalanceMap[targetCurrency] || 0;

        // 포맷팅
        const formattedBalance = balance.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2});

        // 텍스트 업데이트
        const option = accountForeign.options[0];
        if(option) {
            option.text = `${frgnAcctNo} (잔액 ${formattedBalance} ${targetCurrency})`;
        }
    }

    // [서버/Redis API 호출]
    function fetchRate(currencyCode) {
        fetch(`/flobank/exchange/api/rate?currency=${currencyCode}`)
            .then(res => {
                if (!res.ok) throw new Error('Network response was not ok');
                return res.json();
            })
            .then(data => {
                if (data && data.rate) {
                    currentBaseRate = parseFloat(data.rate);

                    // TTS가 있으면 사용, 없으면 임시 계산 (안전장치)
                    if (data.tts) {
                        currentTtsRate = parseFloat(data.tts);
                    } else {
                        currentTtsRate = currentBaseRate * 1.0175; // 안전장치
                    }

                    // TTB 데이터 처리
                    if (data.ttb) {
                        currentTtbRate = parseFloat(data.ttb);
                    } else {
                        currentTtbRate = currentBaseRate * 0.9825; // 안전장치 (약 1.75% 차감)
                    }

                    calculateExchange();
                } else {
                    console.error("Invalid rate data received");
                }
            })
            .catch(err => {
                console.error("Error fetching rate:", err);
            });
    }

    // =========================================
    // 환율 계산 로직 (calculateExchange)
    // =========================================
    function calculateExchange() {
        if (!currentBaseRate || !fromAmount.value) {
            toAmount.value = '';
            if(!fromAmount.value) resultFinal.innerText = '0';
            return;
        }

        const amount = parseFloat(fromAmount.value);
        // 외화 코드가 무엇인지 확인 (USD, JPY 등)
        const foreignCode = (currentMode === 'BUY') ? toCurrency.value : fromCurrency.value;

        // 1. 스프레드(Spread) 계산: 기준율과 고시환율의 차이
        let spread = 0;
        if (currentMode === 'BUY') {
            spread = currentTtsRate - currentBaseRate;
        } else {
            spread = currentBaseRate - currentTtbRate;
        }
        if (spread < 0) spread = 0; // 안전장치

        // 2. 적용 우대율 결정 (기본 우대율 vs 쿠폰 우대율)
        // -> 쿠폰을 선택했다면 쿠폰 우대율을 적용, 아니면 통화별 기본 우대율 적용
        let basePref = BASE_PREF_RATES[foreignCode] || BASE_PREF_RATES['OTHERS'];
        let finalPrefRate = (selectedCouponRate > 0) ? selectedCouponRate : basePref;

        // 3. 개당 최종 수수료 계산
        // 공식: 스프레드 * 수수료율(95%) * (1 - 우대율)
        // 예: 스프레드 10원, 95% 수수료, 70% 우대
        // -> 10 * 0.95 * (1 - 0.7) = 10 * 0.95 * 0.3 = 2.85원 (고객이 내는 돈)
        let unitFee = spread * BASE_FEE_RATE * (1 - finalPrefRate);

        // 4. 최종 적용 환율 도출
        let appliedRate = 0;
        if (currentMode === 'BUY') {
            // 살 때: 기준율 + 수수료 (비싸게 삼)
            appliedRate = currentBaseRate + unitFee;
        } else {
            // 팔 때: 기준율 - 수수료 (싸게 팖)
            appliedRate = currentBaseRate - unitFee;
        }

        // --- UI 표시 및 금액 계산 ---
        let convertVal = 0;
        if (currentMode === 'BUY') {
            // 원화 -> 외화
            if (foreignCode === 'JPY' || foreignCode === 'CNH') {
                convertVal = amount / (appliedRate / 100); // 100단위 통화 처리
            } else {
                convertVal = amount / appliedRate;
            }
            toAmount.value = convertVal.toFixed(2);
        } else {
            // 외화 -> 원화
            if (foreignCode === 'JPY' || foreignCode === 'CNH') {
                convertVal = amount * (appliedRate / 100);
            } else {
                convertVal = amount * appliedRate;
            }
            toAmount.value = Math.floor(convertVal).toLocaleString();
        }

        resultBaseRate.innerText = `${currentBaseRate.toLocaleString()} 원`;
        // 적용 환율 표시 (소수점 2자리)
        resultRate.innerText = `${appliedRate.toFixed(2)} 원`;

        if (currentMode === 'BUY') {
            resultFinal.innerText = `${convertVal.toFixed(2)} ${foreignCode}`;
        } else {
            resultFinal.innerText = `${Math.floor(convertVal).toLocaleString()} KRW`;
        }
    }

    // [드롭다운 옵션 생성 시 data-flag 속성 추가 필수]
    function updateSelectOptions(selectElement, type) {
        selectElement.innerHTML = '';
        if (type === 'FOREIGN') {
            const currencies = [
                {val:'USD', txt:'USD (미국 달러)'},
                {val:'JPY', txt:'JPY (일본 엔)'},
                {val:'EUR', txt:'EUR (유럽 유로)'},
                {val:'CNH', txt:'CNH (중국 위안)'},
                {val:'GBP', txt:'GBP (영국 파운드)'},
                {val:'AUD', txt:'AUD (호주 달러)'}
            ];

            currencies.forEach(c => {
                const opt = document.createElement('option');
                opt.value = c.val;
                opt.text = c.txt;

                // [중요] 동적으로 생성할 때도 이미지 경로를 넣어줘야 함!
                // 파일명이 소문자라고 가정 (예: USD -> /images/usd.png)
                opt.setAttribute('data-flag', `/flobank/images/${c.val.toLowerCase()}.png`);

                selectElement.appendChild(opt);
            });
        }
    }

    // =========================================
    // 5. 환전 신청 버튼 클릭 이벤트
    // =========================================
    const nextBtnStep2 = document.querySelector(".step2-btn-next");

    if (nextBtnStep2) {
        nextBtnStep2.addEventListener("click", () => {
            // 1. 기초 유효성 검사
            if (!fromAmount.value || fromAmount.value <= 0) { alert("금액을 입력해주세요."); return; }
            if (!pwInput.value) { alert("비밀번호를 입력해주세요."); return; }

            let selectedAccount = (currentMode === 'BUY') ? accountWon.value : accountForeign.value;
            if (!selectedAccount) { alert("출금 계좌를 선택해주세요."); return; }

            const inputAmt = parseFloat(fromAmount.value);
            let currentBalance = 0;

            // 2. 잔액 확인 로직 (먼저 수행)
            if (currentMode === 'BUY') {
                const selectedOption = accountWon.options[accountWon.selectedIndex];
                if (selectedOption) {
                    currentBalance = parseFloat(selectedOption.getAttribute('data-balance')) || 0;
                }
            } else {
                const currencyCode = fromCurrency.value;
                currentBalance = frgnBalanceMap[currencyCode] || 0;
            }

            if (inputAmt > currentBalance) {
                const formattedBalance = currentBalance.toLocaleString(undefined, { maximumFractionDigits: 2 });
                const unit = (currentMode === 'BUY') ? '원' : fromCurrency.value;
                alert(`출금 계좌의 잔액이 부족합니다.\n(현재 잔액: ${formattedBalance} ${unit})`);
                return;
            }

            // 3. 수령일 확인 (BUY 모드일 때만)
            if (currentMode === 'BUY' && !receiveDateInput.value) {
                alert("수령 희망일을 선택해주세요.");
                return;
            }

            const requestData = {
                acctNo: selectedAccount,
                acctPw: pwInput.value.trim(),
                mode: currentMode
            };

            // 4. 계좌 비밀번호 확인 (서버 통신)
            fetch('/flobank/exchange/passcheck', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(requestData)
            })
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'success') {
                        // ★★★ [핵심 수정] ★★★
                        // 비밀번호가 일치할 때만 -> 전자서명(CertManager) 실행
                        CertManager.request(
                            "해외송금/환전",
                            fromAmount.value,
                            function() {
                                // 전자서명(팝업)이 완료된 후에만 -> 최종 환전 요청 실행
                                submitExchangeRequest(selectedAccount);
                            }
                        );
                    } else {
                        alert(data.message || "비밀번호가 일치하지 않습니다.");
                        pwInput.value = "";
                        pwInput.focus();
                    }
                })
                .catch(error => {
                    console.error("Error:", error);
                    alert("시스템 오류가 발생했습니다.");
                });
        });
    }

    // =========================================
    // 서버 전송 함수 (submitExchangeRequest)
    // =========================================
    function submitExchangeRequest(sourceAcctNo) {
        // 1. 화면 값 가져오기
        const appliedRateText = document.getElementById("result-rate").innerText.replace(/[^0-9.]/g, "");
        const foreignCode = (currentMode === 'BUY') ? toCurrency.value : fromCurrency.value;

        // 2. 외화 금액 파싱
        let finalForeignAmt = 0;
        if(currentMode === 'BUY') {
            finalForeignAmt = parseFloat(document.getElementById("result-final").innerText.replace(/[^0-9.]/g, ""));
        } else {
            finalForeignAmt = parseFloat(fromAmount.value);
        }

        // 3. 스프레드 재계산
        let spread = 0;
        if (currentMode === 'BUY') {
            spread = currentTtsRate - currentBaseRate;
        } else {
            spread = currentBaseRate - currentTtbRate;
        }
        if (spread < 0) spread = 0;

        // 4. 우대율 및 수수료 재계산 (화면 로직과 동일하게)
        let basePref = BASE_PREF_RATES[foreignCode] || BASE_PREF_RATES['OTHERS'];
        let finalPrefRate = (selectedCouponRate > 0) ? selectedCouponRate : basePref;

        // 개당 수수료 = 스프레드 * 0.95 * (1 - 우대율)
        let unitFee = spread * BASE_FEE_RATE * (1 - finalPrefRate);

        // 전체 수수료(원화) = 개당 수수료 * 외화금액
        // (엔화/위안화 등 100단위 통화일 경우 조정 필요 여부 확인:
        // 보통 spread가 100단위 기준이면 그대로 곱하면 되지만,
        // 1단위 환율 기준이면 그대로 곱함. 여기서는 spread가 1단위 기준이라 가정)

        let totalFeeKrw = 0;
        if (foreignCode === 'JPY' || foreignCode === 'CNH') {
            // JPY는 보통 spread가 100엔당 차액으로 계산되거나 1엔당 차액으로 계산됨.
            // 위 로직에서 unitFee가 100엔당 수수료라면: unitFee * (finalForeignAmt / 100)
            // 하지만 fetchRate에서 받아온 rate가 100엔당 환율이라면 unitFee도 100엔당 값임.
            totalFeeKrw = unitFee * (finalForeignAmt / 100);

            // ※ 주의: 만약 unitFee가 1엔당 수수료라면 그냥 곱하면 됨.
            // 보통 은행 API는 JPY 환율을 100엔 단위로 줍니다. (예: 900.50원)
            // 따라서 unitFee도 100엔당 수수료이므로, 100으로 나눠줘야 정확합니다.
        } else {
            totalFeeKrw = unitFee * finalForeignAmt;
        }

        // 5. 데이터 세팅
        let exchangeData = {
            exchAcctNo: sourceAcctNo,
            exchToCurrency: foreignCode,
            exchAmount: finalForeignAmt,
            exchAppliedRate: parseFloat(appliedRateText),
            exchEsignYn: 'Y',
            exchType: currentMode,
            exchFee: Math.floor(totalFeeKrw)
        };

        // 6. 추가 정보 세팅 (수령지점 or 입금계좌)
        if (currentMode === 'BUY') {
            const branchSelect = document.getElementById("receiveBranch");
            if (!branchSelect.value) { alert("수령 지점을 선택해주세요."); return; }
            const branchName = branchSelect.options[branchSelect.selectedIndex].text;
            const method = document.getElementById("receiveMethod").value;

            exchangeData.exchAddr = `${branchName} (${method === 'ATM' ? 'ATM' : '영업점'})`;
            exchangeData.exchExpDy = document.getElementById("receiveDate").value;
            if (!exchangeData.exchExpDy) { alert("수령일을 선택해주세요."); return; }
        } else {
            const depositAcct = document.getElementById("depositAccountSelect").value;
            // 주소 필드에 입금 계좌 정보 저장
            exchangeData.exchAddr = `즉시입금:${depositAcct}`;
            // 입금은 즉시 처리되므로 오늘 날짜
            exchangeData.exchExpDy = new Date().toISOString().split("T")[0];
        }

        // 7. 서버 전송
        fetch('/flobank/exchange/process', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(exchangeData)
        })
            .then(res => res.json())
            .then(resData => {
                if (resData.status === 'success') {
                    alert("환전 처리가 완료되었습니다.");
                    window.location.href = "/flobank/exchange/step3";
                } else {
                    alert("처리 실패: " + resData.message);
                }
            })
            .catch(err => {
                console.error("Exchange Process Error:", err);
                alert("통신 오류가 발생했습니다.");
            });
    }

    const methodBtns = document.querySelectorAll('.method-btn');
    const receiveMethodInput = document.getElementById('receiveMethod');

    if(methodBtns) {
        methodBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                methodBtns.forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                receiveMethodInput.value = btn.getAttribute('data-value');
            });
        });
    }
});