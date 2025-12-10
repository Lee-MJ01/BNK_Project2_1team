document.addEventListener("DOMContentLoaded", function () {

    /* ----------------------------------------------------
       통화별 최소/최대 금액 값 저장 (key: lmtMinAmt_USD)
    ------------------------------------------------------ */
    const currencyAmountValues = {};

    /* === DOM 참조 === */
    const currencyCheckboxes = document.querySelectorAll('input[name="dpstCurrency"]');
    const currencyAmountContainer = document.getElementById("currencyAmountContainer");

    const depositTypeRadios = document.querySelectorAll('input[name="dpstType"]');
    const extraDepositRadios = document.querySelectorAll('input[name="dpstAddPayYn"]');
    const extraDepositSection = document.querySelector(".conditional.extra-deposit");

    const joinTypeRadios = document.querySelectorAll('input[name="dpstPeriodType"]');
    const joinTypeFree = document.querySelector('.conditional.join-type[data-type="1"]');
    const joinTypeFixed = document.querySelector('.conditional.join-type[data-type="2"]');

    const ageLimitRadios = document.querySelectorAll('input[name="ageLimit"]');
    const ageLimitSection = document.querySelector(".conditional.age-limit");

    const withdrawalRadios = document.querySelectorAll('input[name="dpstPartWdrwYn"]');
    const withdrawalSection = document.querySelector(".conditional.partial-withdrawal");
    const withdrawCurrencyContainer = document.getElementById("withdrawCurrencyContainer");

    const autoRenewRadios = document.querySelectorAll('input[name="dpstAutoRenewYn"]');
    const autoRenewSection = document.querySelector(".conditional.auto-renew");


    /* ----------------------------------------------------
       초기 렌더링
    ------------------------------------------------------ */
    updateAll();


    /* ----------------------------------------------------
       이벤트 등록
    ------------------------------------------------------ */
    depositTypeRadios.forEach(r => r.addEventListener("change", updateAll));
    currencyCheckboxes.forEach(c => c.addEventListener("change", updateAll));
    extraDepositRadios.forEach(r => r.addEventListener("change", updateExtraDeposit));
    joinTypeRadios.forEach(r => r.addEventListener("change", updateJoinType));
    ageLimitRadios.forEach(r => r.addEventListener("change", updateAgeLimit));
    withdrawalRadios.forEach(r => r.addEventListener("change", updateAll));
    autoRenewRadios.forEach(r => r.addEventListener("change", updateAutoRenew));

    /* 값 입력 시 저장 */
    document.addEventListener("input", function (e) {
        const target = e.target;
        const code = target.dataset.code;

        if (!code) return;

        if (target.name === "lmtMinAmt[]") {
            currencyAmountValues[`lmtMinAmt_${code}`] = target.value;
        }
        if (target.name === "lmtMaxAmt[]") {
            currencyAmountValues[`lmtMaxAmt_${code}`] = target.value;
        }
    });


    /* ----------------------------------------------------
       전체 업데이트
    ------------------------------------------------------ */
    function updateAll() {
        updateDepositType();
        updateExtraDeposit();
        updateJoinType();
        updateAgeLimit();
        updateWithdrawal();
        updateAutoRenew();
    }


    /* ----------------------------------------------------
       예금 유형 (거치식일 때만 통화별 금액 보이기)
    ------------------------------------------------------ */
    function updateDepositType() {
        const selectedType = document.querySelector('input[name="dpstType"]:checked').value;

        const rate1 = document.querySelector('input[name="dpstRateType"][value="1"]');
        const rate2 = document.querySelector('input[name="dpstRateType"][value="2"]');
        const rate3 = document.querySelector('input[name="dpstRateType"][value="3"]');

        const rate1Label = rate1.closest("label");
        const rate2Label = rate2.closest("label");
        const rate3Label = rate3.closest("label");

        if (selectedType === "1") {
            /* 거치식 예금 */
            rate1Label.style.display = "inline-flex";
            rate2Label.style.display = "inline-flex";
            rate3Label.style.display = "none";

            rate1.disabled = false;
            rate2.disabled = false;
            rate3.disabled = true;

            // 기본값: 가입 시점(1)
            rate1.checked = true;

        } else {
            /* 자유 적립식 */
            rate1Label.style.display = "none";
            rate2Label.style.display = "none";
            rate3Label.style.display = "inline-flex";

            // 납입 시 환율만 선택 + 고정
            rate3.checked = true;
            rate3.disabled = false;

            rate1.disabled = true;
            rate2.disabled = true;
        }

        /* 기존 기능 유지 (예금 유형 섹션 show/hide) */
        if (selectedType === "1") {
            document.querySelector(".conditional.deposit-type").style.display = "block";
            updateCurrencyAmountFields();
        } else {
            document.querySelector(".conditional.deposit-type").style.display = "none";
            currencyAmountContainer.innerHTML = "";
        }
    }


    /* ----------------------------------------------------
       통화별 최소/최대 금액 생성
    ------------------------------------------------------ */
    function updateCurrencyAmountFields() {
        const selectedType = document.querySelector('input[name="dpstType"]:checked').value;
        if (selectedType !== "1") return;

        currencyAmountContainer.innerHTML = "";

        const checkedCurrencyBoxes = Array.from(currencyCheckboxes).filter(c => c.checked);

        checkedCurrencyBoxes.forEach(box => {
            const code = box.value;
            const label = box.parentElement.textContent.trim();

            const minKey = `lmtMinAmt_${code}`;
            const maxKey = `lmtMaxAmt_${code}`;

            const block = document.createElement("div");
            block.classList.add("currency-amount-block");

            block.innerHTML = `
                <h4>${label}</h4>
            
                <input type="hidden" name="lmtCurrency[]" value="${code}">
                
                <div class="form-inline">
                    <label>최소 가입액</label>
                    <input type="number" name="lmtMinAmt[]" data-code="${code}" 
                           value="${currencyAmountValues[minKey] || ''}">
                </div>
            
                <div class="form-inline">
                    <label>최대 가입액</label>
                    <input type="number" name="lmtMaxAmt[]" data-code="${code}" 
                           value="${currencyAmountValues[maxKey] || ''}">
                </div>
            `;

            currencyAmountContainer.appendChild(block);
        });
    }


    /* ----------------------------------------------------
       추가 납입
    ------------------------------------------------------ */
    function updateExtraDeposit() {
        const selected = document.querySelector('input[name="dpstAddPayYn"]:checked').value;
        extraDepositSection.style.display = (selected === "Y") ? "block" : "none";
    }


    /* ----------------------------------------------------
       가입기간 유형
    ------------------------------------------------------ */
    function updateJoinType() {
        const selected = document.querySelector('input[name="dpstPeriodType"]:checked').value;

        joinTypeFree.style.display = (selected === "1") ? "block" : "none";
        joinTypeFixed.style.display = (selected === "2") ? "block" : "none";
    }


    /* ----------------------------------------------------
       나이 제한
    ------------------------------------------------------ */
    function updateAgeLimit() {
        const selected = document.querySelector('input[name="ageLimit"]:checked').value;
        ageLimitSection.style.display = (selected === "yes") ? "block" : "none";
    }


    /* ----------------------------------------------------
       분할 인출
    ------------------------------------------------------ */
    function updateWithdrawal() {
        const selected = document.querySelector('input[name="dpstPartWdrwYn"]:checked').value;
        const type = document.querySelector('input[name="dpstType"]:checked').value;

        withdrawCurrencyContainer.innerHTML = "";

        if (selected === "N") {
            withdrawalSection.style.display = "none";
            return;
        }

        withdrawalSection.style.display = "block";

        if (type === "1") updateCurrencyWithdrawFields();
    }


    /* 통화별 최소 출금 금액 */
    function updateCurrencyWithdrawFields() {

        const selectedCurrencies = Array.from(currencyCheckboxes).filter(c => c.checked);

        withdrawCurrencyContainer.innerHTML = "";

        selectedCurrencies.forEach(currency => {
            const label = currency.parentElement.textContent.trim();

            const block = document.createElement("div");
            block.classList.add("currency-amount-block");

            block.innerHTML = `
                <h4>${label} 최소 출금 금액</h4>
                <div class="form-inline">
                    <label>최소 출금금액</label>
                    <input type="number" name="minWithdraw_${currency.value}"
                        placeholder="예: ${currency.value} 최소 금액" />
                </div>
            `;

            withdrawCurrencyContainer.appendChild(block);
        });
    }


    /* ----------------------------------------------------
       자동연장
    ------------------------------------------------------ */
    function updateAutoRenew() {
        const selected = document.querySelector('input[name="dpstAutoRenewYn"]:checked').value;
        autoRenewSection.style.display = (selected === "Y") ? "block" : "none";
    }






});
