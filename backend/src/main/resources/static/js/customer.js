
document.addEventListener('DOMContentLoaded', () => {
  const faqItems = document.querySelectorAll('.faq-question');

  faqItems.forEach((item) => {
    item.addEventListener('click', () => {
      const parent = item.parentNode;
      parent.classList.toggle('active');
    });
  });
});