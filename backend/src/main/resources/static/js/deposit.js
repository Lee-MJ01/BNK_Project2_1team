
function openTab(evt, tabName) {
    var i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("view-content");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("view-tab");
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].classList.remove("active");
    }
    document.getElementById(tabName).style.display = "block";
    evt.currentTarget.classList.add("active");
}


function fetchRateData(baseDate) {
    const tableBody = document.getElementById('rateTableBody');
    if (!tableBody) return; // 테이블이 없는 페이지에서는 실행하지 않음

    // 로딩 상태 표시
    tableBody.innerHTML = `<tr><td colspan="13" class="no-data" style="padding: 30px; text-align: center; color: #999;">데이터를 불러오는 중...</td></tr>`;

    // AJAX를 사용하여 백엔드(Controller)에 요청
    fetch(`/flobank/deposit/rates?baseDate=${baseDate}`)
        .then(response => {
            if (!response.ok) {
                // HTTP 오류 상태 (404, 500 등) 처리
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            if (data.length === 0) {
                tableBody.innerHTML = `<tr><td colspan="13" class="no-data" style="padding: 30px; text-align: center; color: #999;">${baseDate}에 조회된 금리 데이터가 없습니다.</td></tr>`;
                return;
            }

            let html = '';

            // 데이터를 테이블 행으로 변환
            data.forEach(item => {
                // 금리를 소수점 2자리까지 표시하는 보조 함수
                const formatRate = (rate) => {
                    if (rate == null || parseFloat(rate) === 0 || isNaN(parseFloat(rate))) {
                        return '0';
                    }
                    return parseFloat(rate).toFixed(2);
                };

                html += '<tr>';
                html += `<th>${item.currency}</th>`;
                // DTO 필드명 (rate1M ~ rate12M)을 사용하여 값 표시
                html += `<td>${formatRate(item.rate1M)}</td>`;
                html += `<td>${formatRate(item.rate2M)}</td>`;
                html += `<td>${formatRate(item.rate3M)}</td>`;
                html += `<td>${formatRate(item.rate4M)}</td>`;
                html += `<td>${formatRate(item.rate5M)}</td>`;
                html += `<td>${formatRate(item.rate6M)}</td>`;
                html += `<td>${formatRate(item.rate7M)}</td>`;
                html += `<td>${formatRate(item.rate8M)}</td>`;
                html += `<td>${formatRate(item.rate9M)}</td>`;
                html += `<td>${formatRate(item.rate10M)}</td>`;
                html += `<td>${formatRate(item.rate11M)}</td>`;
                html += `<td>${formatRate(item.rate12M)}</td>`;
                html += '</tr>';
            });

            tableBody.innerHTML = html;
        })
        .catch(error => {
            console.error('금리 데이터 조회 에러:', error);
            tableBody.innerHTML = `<tr><td colspan="13" class="no-data" style="padding: 30px; text-align: center; color: #d12a2a;">데이터를 불러오는 중 오류가 발생했습니다. (콘솔 확인)</td></tr>`;
        });
}

// ==========================================================
// 2. DOMContentLoaded 영역: 페이지 로드 후 이벤트 리스너 설정
// ==========================================================

document.addEventListener("DOMContentLoaded", () => {

    const tabs = document.querySelectorAll('.view-tab');
    const contents = document.querySelectorAll('.view-content');

    tabs.forEach((tab, index) => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => t.classList.remove('active'));
            contents.forEach(c => c.classList.remove('active'));

            tab.classList.add('active');
            contents[index].classList.add('active');
        });
    });

    // 🔹 만기자동연장신청 토글
    const radioApply = document.querySelector('input[name="autoRenewYn"][value="y"]');
    const radioNo = document.querySelector('input[name="autoRenewYn"][value="n"]');
    const extraFields = document.getElementById("autoRenewFields");

    if (radioApply && radioNo && extraFields) {
        radioApply.addEventListener("change", () => {
            if (radioApply.checked) extraFields.classList.remove("hidden");
        });
        radioNo.addEventListener("change", () => {
            if (radioNo.checked) extraFields.classList.add("hidden");
        });
    }

    // 🔹 이메일 / 문자 수령방법 전환
    const emailRadio = document.querySelector('input[name="receiveMethod"][value="email"]');
    const smsRadio = document.querySelector('input[name="receiveMethod"][value="sms"]');
    const emailFields = document.getElementById("emailFields");
    const smsHint = document.getElementById("smsHint");

    if (emailRadio && smsRadio && emailFields && smsHint) {
        emailRadio.addEventListener("change", () => {
            if (emailRadio.checked) {
                emailFields.classList.remove("hidden");
                smsHint.classList.add("hidden");
            }
        });
        smsRadio.addEventListener("change", () => {
            if (smsRadio.checked) {
                emailFields.classList.add("hidden");
                smsHint.classList.remove("hidden");
            }
        });
    }

    // 🔹 원화/외화 출금계좌 토글
    const krwRadio = document.querySelector('input[name="withdrawType"][value="krw"]');
    const fxRadio = document.querySelector('input[name="withdrawType"][value="fx"]');
    const krwFields = document.getElementById("krwFields");
    const fxFields = document.getElementById("fxFields");

    if (krwRadio && fxRadio && krwFields && fxFields) {
        krwRadio.addEventListener("change", () => {
            if (krwRadio.checked) {
                krwFields.classList.remove("hidden");
                fxFields.classList.add("hidden");
            }
        });
        fxRadio.addEventListener("change", () => {
            if (fxRadio.checked) {
                fxFields.classList.remove("hidden");
                krwFields.classList.add("hidden");
            }
        });
    }

    // 🔹 원화 출금계좌 잔액 힌트 업데이트
    const select = document.getElementById("withdrawAccount");
    const balanceHint = document.getElementById("balanceHint");

    if (select){
        select.addEventListener("change", () => {
            const selectedOption = select.options[select.selectedIndex];
            const balance = selectedOption.getAttribute("data-balance") || "0";
            console.log("선택 변경됨");
            console.log("선택된 balance = ", selectedOption.getAttribute("data-balance"));

            const formattedBalance = Number(balance).toLocaleString()
            balanceHint.textContent = `출금가능금액 ${formattedBalance}원`;
        });
    }

    // 🔹 외화 출금계좌 잔액 힌트 업데이트
    const frgnSelect = document.getElementById("withdrawFrgnAccount");
    const frgnBalanceHint = document.getElementById("frgnBalanceHint");

    if (frgnSelect){
        frgnSelect.addEventListener("change", () => {
            const fselectedOption = frgnSelect.options[frgnSelect.selectedIndex];
            const fbalance = fselectedOption.getAttribute("data-balance") || "0";
            const fcurrency = fselectedOption.getAttribute("data-currency");

            const fformattedBalance = Number(fbalance).toLocaleString()
            frgnBalanceHint.textContent = `출금가능금액 ${fformattedBalance} ${fcurrency}`;
        });
    }


    const curSelect = document.getElementById("curSelect");
    const amountInput = document.querySelector("#lmtAmtInput .form-input");

    if (curSelect && amountInput) {
        curSelect.addEventListener("change", () => {
            const opt = curSelect.options[curSelect.selectedIndex];

            const curName = opt.getAttribute("data-curName");
            const curCode = opt.getAttribute("data-curCode");
            const minAmount = opt.getAttribute("data-minAmount");
            const maxAmount = opt.getAttribute("data-maxAmount");

            if (minAmount && !isNaN(minAmount) && maxAmount && !isNaN(maxAmount)) {
                amountInput.placeholder = `${Number(minAmount).toLocaleString()}${curCode} 이상, ${Number(maxAmount).toLocaleString()}${curCode} 미만`;
            } else if (minAmount && !isNaN(minAmount)) {
                amountInput.placeholder = `${Number(minAmount).toLocaleString()}${curCode} 이상`;
            } else if (maxAmount && !isNaN(maxAmount)) {
                amountInput.placeholder = `${Number(maxAmount).toLocaleString()}${curCode} 미만`;
            } else {
                amountInput.placeholder = `${curName} 금액 입력`;
            }
        });
    }


    // 🔹 금리 조회 (날짜 변경 이벤트 리스너)
    const searchDateInput = document.getElementById('searchDate');

    if (searchDateInput) {
        // 날짜를 선택(change)하면 fetchRateData 함수(전역)를 호출합니다.
        searchDateInput.addEventListener('change', (e) => {
            const selectedDate = e.target.value;
            if (selectedDate) {
                fetchRateData(selectedDate);
            }
        });
    }


    const curSelection = document.getElementById('curSelect');
    const curSelectionName = document.getElementById("selectedCurName");
    if (curSelection && curSelectionName) {
        curSelection.addEventListener('change', function() {
            const cur = this.options[this.selectedIndex].getAttribute("data-curName");
            curSelectionName.value = cur;
        });
    }

    const nextBtn = document.querySelector(".step1-btn-next");

    if (nextBtn) {
        nextBtn.addEventListener("click", (e) => {
            const checkboxes = document.querySelectorAll(".step1-checkbox");
            const allChecked = Array.from(checkboxes).every(cb => cb.checked);

            if (!allChecked) {
                e.preventDefault(); // 이동 막기
                alert("필수 항목을 모두 확인하고 체크해 주세요.");
            }
        });
    }


    const joinBtn = document.querySelector(".view-btn-primary"); // 가입하기 버튼
    const listJoinBtn = document.querySelector(".list-join-btn"); // 가입하기 버튼
    const today = new Date();
    const day = today.getDay();

    if (joinBtn) {
        joinBtn.addEventListener("click", (e) => {
            // 0:일, 6:토
            if (day === 0 || day === 6) {
                e.preventDefault(); // 이동 막기
                alert("주말(비영업일)에는 예금 신규 가입이 불가능합니다.\n평일에 다시 시도해 주세요.");
            }
        });
    }

    if (listJoinBtn) {
        listJoinBtn.addEventListener("click", (e) => {
            if (day === 0 || day === 6) {
                e.preventDefault(); // 이동 막기
                alert("주말(비영업일)에는 예금 신규 가입이 불가능합니다.\n평일에 다시 시도해 주세요.");
            }
        });
    }

    // --------------------------------------------------------
    // [Step 3] 간편인증 연동 로직
    // --------------------------------------------------------
    const btnCertComplete = document.getElementById("btn-cert-complete");

    if (btnCertComplete) {
        btnCertComplete.addEventListener("click", function() {

            // 1. 폼 요소 가져오기
            const finalForm = document.getElementById("depositFinalForm");

            // 2. 인증창에 띄울 정보 수집 (Hidden Input 값 활용)
            // 상품명 (HTML 테이블에서 텍스트를 가져오거나 하드코딩)
            const productName = "BNK 모아드림 외화적금 가입";

            // 출금 유형 (krw: 원화, fx: 외화)
            const withdrawType = document.querySelector('input[name="withdrawType"]').value;

            let authAmount = ""; // 인증창에 띄울 문자열 (예: "1,000,000 원")

            if (withdrawType === 'krw') {
                // 원화 출금 시: 원화 환산 금액 사용
                const krwVal = document.querySelector('input[name="krwAmount"]').value;
                authAmount = Number(krwVal).toLocaleString() + " 원";
            } else {
                // 외화 출금 시: 외화 금액 사용
                const fxVal = document.querySelector('input[name="dpstAmount"]').value;
                const currency = document.querySelector('input[name="dpstHdrCurrency"]').value;
                authAmount = Number(fxVal).toLocaleString() + " " + currency;
            }

            // 3. CertManager 호출 (common_cert.js에 정의된 객체)
            // 파라미터: (제목, 금액, 성공시콜백함수)
            CertManager.request(productName, authAmount, function() {
                // [콜백] 인증 성공 시 실행되는 부분
                // 실제 폼을 서버로 제출
                finalForm.submit();
            });
        });
    }


    const calcBtn = document.getElementById("calcBtn");
    if (calcBtn) {
      calcBtn.addEventListener("click", async () => {

          const curS = document.getElementById("curSelect");
        const curSelected = curS.options[curS.selectedIndex];
        const currencyCode = curSelected.value;
        const foreignAmountInput = document.getElementById("foreignAmount");
        const foreignAmount = document.getElementById("foreignAmount").value;

        if (!foreignAmount || isNaN(foreignAmount)) {
            alert("외화 금액을 올바르게 입력해 주세요.");
            foreignAmountInput.value = "";
            foreignAmountInput.focus();
            return;
        }

        const minAmount = Number(curSelected.getAttribute("data-minAmount"));
        const maxAmount = Number(curSelected.getAttribute("data-maxAmount"));

        // 입력값 숫자 체크
        if (!foreignAmount || isNaN(foreignAmount)) {
            alert("금액을 숫자로 입력해 주세요.");
            return;
        }

        const amt = Number(foreignAmount);

        // 🔥 범위 검사
        if ((minAmount && amt < minAmount) || (maxAmount && amt >= maxAmount)) {
            alert(`입력 가능 금액은 ${minAmount.toLocaleString()}${currencyCode} 이상 ${
                maxAmount ? maxAmount.toLocaleString() + currencyCode + " 미만" : ""
            }입니다.`);
            foreignAmountInput.value = "";
            foreignAmountInput.focus();
            return;
        }

        try {
            const res = await fetch("/flobank/deposit/calc", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    amount: foreignAmount,
                    currency : currencyCode
                })
            });


            const data = await res.json();  // 백엔드 반환값
            updateTable(data, foreignAmount, curSelected.getAttribute("data-curName"));              // 값 반영

        } catch (e) {
            console.error(e);
            alert("계산 중 오류가 발생했습니다.");
        }
      });
    }

    function numberFormat(value) {
        if (value === null || value === undefined) return "0";
        return Number(value).toLocaleString("ko-KR");
    }

    function updateTable(data, foreignAmount, curName) {
        const table = document.getElementById("calcResultTable");

        table.innerHTML = `
           <input type="hidden" name="selectedCurName" value="${curName}">
        <tr>
                <td class="prod-amt-left">
                    송금보내실때환율
                </td>
                <td class="prod-amt-right">
                    ${numberFormat(data.ttsRate)} 원
                </td>
            </tr>
            <tr>
                <td class="prod-amt-left">
                    우대적용환율
                </td>
                <td class="prod-amt-right">
                    <input type="hidden" name="appliedRate" value="${Number(data.appliedRate)}">
                    ${numberFormat(data.appliedRate)} 원
                </td>
            </tr>
            <tr>
                <td class="prod-amt-left">
                    우대율
                </td>
                <td class="prod-amt-right">
                    ${data.prefRate}%
                </td>
            </tr>
            <tr>
                <td class="prod-amt-left">
                    우대받는금액
                </td>
                <td class="prod-amt-right">
                    ${numberFormat(Number(data.spreadHalfPref) * Number(foreignAmount))} 원
                </td>
            </tr>
            <tr>
                <td class="prod-amt-left">
                    예상원화금액
                </td>
                <td class="prod-amt-right" style="color: #ef0909; font-weight: bold">
                    <input type="hidden" name="krwAmount" value="${Number(data.krwAmount)}">
                    ${numberFormat(data.krwAmount)} 원
                </td>
            </tr>
            <tr>
                <td class="prod-amt-left" colspan="2" style="color: gray">
                    상기 예상금액은 실제 가입 시점의 환율 변동에 따라 달라질 수 있습니다.(수수료 미포함)
                </td>
            </tr>
        `;


        // 테이블 표시
        table.style.display = "table";
    }

    const periodInput = document.getElementById("periodInput");

    if (periodInput) {
        periodInput.addEventListener("change", () => {
            const min = Number(periodInput.dataset.min);
            const max = Number(periodInput.dataset.max);
            const value = Number(periodInput.value);

            if (value < min || value > max) {
                alert(`가입 가능한 기간은 ${min}개월 이상 ${max}개월 이하입니다.`);
                periodInput.value = ""; // 입력값 초기화
                periodInput.focus();    // 다시 입력하도록 포커스 이동
            }
        });
    }

    const depositRegForm = document.getElementById("depositRegForm");
    if (depositRegForm){
        depositRegForm.addEventListener("submit", function (e) {
            // 출금 계좌 비밀번호
            const withdrawType = document.querySelector('input[name="withdrawType"]:checked').value;
            const acctPw = document.querySelector('input[name="acctPw"]')?.value;           // 원화
            const frgnAcctPw = document.querySelector('input[name="frgnAcctPw"]')?.value;   // 외화

            if (withdrawType === "krw") {
                const withdrawAccount = document.getElementById("withdrawAccount");
                if (!withdrawAccount.value || withdrawAccount.selectedIndex === 0) {
                    alert("출금 계좌를 선택해 주세요.");
                    e.preventDefault();
                    return;
                }
            } else if (withdrawType === "fx") {
                const frgnSelect = document.getElementById("withdrawFrgnAccount");
                if (!frgnSelect.value || frgnSelect.selectedIndex === 0) {
                    alert("외화 출금 통화를 선택해 주세요.");
                    e.preventDefault();
                    return;
                }
            }




            // 4자리 입력 여부 체크
            if (withdrawType === "krw") {
                if (!acctPw || acctPw.length !== 4) {
                    alert("출금계좌 비밀번호를 정확히 입력해 주세요.");
                    e.preventDefault();
                    return;
                }
            } else if (withdrawType === "fx") {
                if (!frgnAcctPw || frgnAcctPw.length !== 4) {
                    alert("외화출금계좌 비밀번호를 정확히 입력해 주세요.");
                    e.preventDefault();
                    return;
                }
            }

            const curSelect = document.getElementById("curSelect");
            if (!curSelect.value || curSelect.selectedIndex === 0) {
                alert("신규 통화 종류를 선택해 주세요.");
                e.preventDefault();
                return;
            }

            const foreignAmount = document.getElementById("foreignAmount").value;
            if (!foreignAmount) {
                alert("신규 금액을 입력해 주세요.");
                e.preventDefault();
                return;
            }

            const periodFixed = document.querySelector('select[name="dpstHdrMonth"]');
            const periodInput = document.getElementById("periodInput");

            if (periodFixed && periodFixed.value !== undefined) {
                if (!periodFixed.value) {
                    alert("가입 기간을 선택해 주세요.");
                    e.preventDefault();
                    return;
                }
            } else if (periodInput) {
                if (!periodInput.value) {
                    alert("가입 기간을 입력해 주세요.");
                    e.preventDefault();
                    return;
                }
            }


            // 정기예금 비밀번호 & 확인
            const dpstPw = document.getElementById("dpstPw").value;
            const dpstPwCheck = document.getElementById("dpstPwCheck").value;

            if (!dpstPw ) {
                alert("정기예금 비밀번호를 입력해 주세요.");
                e.preventDefault();
                return;
            }

            if ( dpstPw.length !== 4) {
                alert("정기예금 비밀번호를 정확히 입력해 주세요.");
                e.preventDefault();
                return;
            }

            if (!dpstPwCheck) {
                alert("비밀번호 확인란을 입력해 주세요.");
                e.preventDefault();
                return;
            }

            if (dpstPw !== dpstPwCheck) {
                alert("정기예금 비밀번호가 일치하지 않습니다.");
                e.preventDefault();
                return;
            }

            const autoRenewRadio = document.querySelector('input[name="autoRenewYn"][value="apply"]');
            if (autoRenewRadio && autoRenewRadio.checked) {
                const autoRenewTerm = document.querySelector('select[name="autoRenewTerm"]');
                if (!autoRenewTerm.value) {
                    alert("자동연장 주기 월수를 선택해 주세요.");
                    e.preventDefault();
                    return;
                }
            }

            const withdrawT = document.querySelector('input[name="withdrawType"]:checked').value;
            const foreignA = Number(document.getElementById("foreignAmount").value);

            // 원화/외화 출금 계좌 잔액
            let balance = 0;
            if (withdrawT === "krw") {
                const selected = document.querySelector('#withdrawAccount option:checked');
                balance = Number(selected.getAttribute("data-balance"));
            } else if (withdrawT === "fx") {
                const selected = document.querySelector('#withdrawFrgnAccount option:checked');
                balance = Number(selected.getAttribute("data-balance"));
            }

            // 예상 원화금액 (calc 버튼 클릭 후 테이블 생성된 경우)
            const krwAmountInput = document.querySelector('input[name="krwAmount"]');
            const krwAmount = krwAmountInput ? Number(krwAmountInput.value) : null;

            /* -----------------------
               🔥 금액 유효성 체크
            ------------------------*/

            if (withdrawT === "krw") {
                // 원화 계좌에서 출금 = 계산된 예상 원화금액 기준 비교
                if (!krwAmount) {
                    alert("예상금액확인을 먼저 진행해 주세요.");
                    e.preventDefault();
                    return;
                }
                if (krwAmount > balance) {
                    alert("출금 가능 금액보다 큰 금액입니다.");
                    e.preventDefault();
                    return;
                }
            } else if (withdrawT === "fx") {
                // 외화 계좌에서 출금 = 입력된 외화 금액 기준 비교
                if (foreignA > balance) {
                    alert("출금 가능 외화 잔액보다 큰 금액입니다.");
                    e.preventDefault();
                    return;
                }
            }
        });

        const dpstPw = document.getElementById("dpstPw");
        const dpstPwCheck = document.getElementById("dpstPwCheck");
        const pwError = document.getElementById("pwError");

        if (dpstPwCheck) {
            dpstPwCheck.addEventListener("input", () => {
                if (dpstPw.value !== dpstPwCheck.value) {
                    pwError.style.display = "block";
                } else {
                    pwError.style.display = "none";
                }
            });
        }
    }
});

function confirmBeforeBack() {
    return confirm("이전 단계로 이동하면 현재 입력한 정보가 모두 사라집니다.\n계속하시겠습니까?");
}


