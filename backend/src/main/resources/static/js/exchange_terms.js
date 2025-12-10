// ---------------------------------------------------------------
// exchange_terms.js
// 환전 약관동의 전용 스크립트
// ---------------------------------------------------------------

document.addEventListener("DOMContentLoaded", () => {
    console.log("[exchange_terms.js] 실행됨");

    const agreeAll = document.getElementById("agreeAll");
    const checks = document.querySelectorAll(".term-check");
    const form = document.getElementById("remitTermsForm");

    // 필수 요소 없으면 종료
    if (!agreeAll || checks.length === 0 || !form) {
        console.warn("[exchange_terms.js] 필수 요소 부족 → 스크립트 중단");
        return;
    }

    // -----------------------------
    // 1) 전체 동의 클릭
    // -----------------------------
    agreeAll.addEventListener("change", () => {
        const checked = agreeAll.checked;
        checks.forEach(chk => (chk.checked = checked));
    });

    // -----------------------------
    // 2) 개별 동의 → 전체동의 상태 업데이트
    // -----------------------------
    checks.forEach(chk => {
        chk.addEventListener("change", () => {
            agreeAll.checked = [...checks].every(c => c.checked);
        });
    });

    // -----------------------------
    // 3) 제출 시 검사
    // -----------------------------
    form.addEventListener("submit", e => {
        const allChecked = [...checks].every(c => c.checked);

        if (!allChecked) {
            e.preventDefault();
            alert("모든 약관에 동의해야 다음 단계로 진행할 수 있습니다.");
            return;
        }
    });

});
