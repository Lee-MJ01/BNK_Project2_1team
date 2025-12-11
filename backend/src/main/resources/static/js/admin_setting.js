document.addEventListener("DOMContentLoaded", () => {
  const filterForm = document.getElementById("qnaFilterForm");
  const filterSelect = document.getElementById("qna-status-filter");

  if (filterForm && filterSelect) {
    filterSelect.addEventListener("change", () => {
      // 새 상태로 필터링할 때는 첫 페이지부터 다시 조회
      const qnaPageInput = filterForm.querySelector('input[name="qnaPage"]');
      if (qnaPageInput) {
        qnaPageInput.value = 1;
      }
      const action = filterForm.getAttribute("action") || window.location.pathname;
      filterForm.setAttribute("action", `${action}#qna-list`);
      filterForm.submit();
    });
  }
});
