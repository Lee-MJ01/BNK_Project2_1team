document.addEventListener("DOMContentLoaded", () => {

    ////////////////////////////////////////////////////////////////////////////
    // 1️⃣ 외화계좌 이체 약관 체크 (필수)
    ////////////////////////////////////////////////////////////////////////////
    const agreeAll = document.getElementById("agreeAll");
    const checks = document.querySelectorAll(".term-check");
    const remitTermsForm = document.getElementById("remitTermsForm");

    if (remitTermsForm && agreeAll && checks.length > 0) {

        // 전체 동의 클릭 시
        agreeAll.addEventListener("change", () => {
            checks.forEach(c => (c.checked = agreeAll.checked));
        });

        // 개별 클릭 시 전체 동의 상태 업데이트
        checks.forEach(chk => {
            chk.addEventListener("change", () => {
                agreeAll.checked = [...checks].every(c => c.checked);
            });
        });

        // 제출 차단
        remitTermsForm.addEventListener("submit", (e) => {
            const allChecked = [...checks].every(c => c.checked);

            if (!allChecked) {
                e.preventDefault();
                alert("모든 약관에 동의해야 다음 단계로 진행할 수 있습니다.");
            }
        });
    }

});
