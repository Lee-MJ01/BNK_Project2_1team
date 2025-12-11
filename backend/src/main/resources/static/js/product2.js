document.addEventListener("DOMContentLoaded", function () {

    const approveUrl = "/flobank/admin/products/approve/";

    const tabs = document.querySelectorAll(".tab-btn");
    const approveTable = document.querySelector("[data-status-group='approve']");
    const pendingTable = document.querySelector("[data-status-group='pending']");

    // 탭 전환
    tabs.forEach(btn => {
        btn.addEventListener("click", () => {
            tabs.forEach(b => b.classList.remove("active"));
            btn.classList.add("active");

            if (btn.dataset.status === "approve") {
                approveTable.style.display = "";
                pendingTable.style.display = "none";
            } else {
                approveTable.style.display = "none";
                pendingTable.style.display = "";
            }
        });
    });

    // 승인 처리
    document.querySelectorAll(".btn-approve").forEach(btn => {

        btn.addEventListener("click", function () {

            const row = this.closest("tr");
            const dpstId = row.dataset.id;
            const productName = row.children[0].textContent;

            if (!confirm(`${productName} 상품을 승인하시겠습니까?`)) return;

            fetch("/flobank/admin/products/approve/" + dpstId, {
                method: "POST"
            })
                .then(res => {
                    if (!res.ok) throw new Error("승인 요청 실패");
                })
                .then(() => {
                    row.remove();

                    const newRow = document.createElement("tr");
                    newRow.dataset.status = "pending";
                    newRow.dataset.id = dpstId;

                    newRow.innerHTML = `
                        <td>${productName}</td>
                        <td><span class="status-badge status-pending">상품 등록 대기 중</span></td>
                        <td></td>
                    `;

                    pendingTable.querySelector("tbody").appendChild(newRow);

                    alert("승인이 완료되었습니다.");
                })
                .catch(err => console.error(err));
        });
    });

});
