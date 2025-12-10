document.addEventListener("DOMContentLoaded", () => {
  const tabs = document.querySelectorAll(".search-tabs li");
  const sections = document.querySelectorAll(".search-section");
  const moreButtons = document.querySelectorAll(".more");

  tabs.forEach(tab => {
    tab.addEventListener("click", () => switchTab(tab.dataset.tab));
  });

  moreButtons.forEach(btn => {
    btn.addEventListener("click", () => switchTab(btn.dataset.tab));
  });

  function switchTab(tabName) {
    tabs.forEach(t => t.classList.remove("active"));
    sections.forEach(section => {
      const more = section.querySelector(".more");

      if (tabName === "all") {
        section.style.display = "block";
        section.querySelectorAll(".hidden").forEach(el => (el.style.display = "none"));
        if (more) more.style.display = "inline"; // 더보기 보이기
      } else if (section.dataset.tab === tabName) {
        section.style.display = "block";
        section.querySelectorAll(".hidden").forEach(el => (el.style.display = "list-item"));
        if (more) more.style.display = "none"; // 더보기 숨기기
        document.querySelector(`.search-tabs li[data-tab="${tabName}"]`).classList.add("active");
      } else {
        section.style.display = "none";
      }
    });
  }
});