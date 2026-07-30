(function () {
  const btn = document.getElementById('mobile-menu-btn');
  const menu = document.getElementById('mobile-menu');
  if (!btn || !menu) return;

  const iconOpen = btn.querySelector('[data-icon="open"]');
  const iconClose = btn.querySelector('[data-icon="close"]');

  function setExpanded(expanded) {
    menu.classList.toggle('hidden', !expanded);
    btn.setAttribute('aria-expanded', String(expanded));
    if (iconOpen) iconOpen.classList.toggle('hidden', expanded);
    if (iconClose) iconClose.classList.toggle('hidden', !expanded);
  }

  btn.addEventListener('click', () => {
    setExpanded(menu.classList.contains('hidden'));
  });

  menu.addEventListener('click', (event) => {
    if (event.target.closest('a')) setExpanded(false);
  });
})();
