// Progressive enhancement for the home page: publication filter, older news,
// theme toggle. Every control is rendered hidden and only shown here, so the
// page is complete without JavaScript.
(function () {
  'use strict';
  var root = document.documentElement;

  // ---- theme ----
  var themeBtn = document.querySelector('[data-theme-toggle]');
  var darkQuery = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;

  function effectiveTheme() {
    var t = root.getAttribute('data-theme');
    if (t === 'light' || t === 'dark') return t;
    return darkQuery && darkQuery.matches ? 'dark' : 'light';
  }

  function renderThemeButton() {
    var dark = effectiveTheme() === 'dark';
    var label = dark ? 'Switch to light theme' : 'Switch to dark theme';
    themeBtn.querySelector('.emo').textContent = dark ? '☀️' : '🌙';
    themeBtn.setAttribute('aria-label', label);
    themeBtn.title = label;
  }

  if (themeBtn) {
    themeBtn.hidden = false;
    renderThemeButton();
    themeBtn.addEventListener('click', function () {
      var next = effectiveTheme() === 'dark' ? 'light' : 'dark';
      root.setAttribute('data-theme', next);
      try { localStorage.setItem('theme', next); } catch (e) { /* storage blocked: theme lasts this visit only */ }
      renderThemeButton();
    });
    if (darkQuery && darkQuery.addEventListener) darkQuery.addEventListener('change', renderThemeButton);
  }

  // ---- publications: Selected / All ----
  var pubs = document.querySelector('[data-pubs]');
  var filter = pubs && pubs.querySelector('[data-pub-filter]');
  if (filter) {
    var headSep = pubs.querySelector('[data-head-sep]');
    if (headSep) headSep.hidden = false;
    var title = pubs.querySelector('[data-pub-title]');
    var rows = pubs.querySelectorAll('article.pub');
    var years = pubs.querySelectorAll('.pub-year');
    var show = function (mode) {
      var all = mode === 'all';
      rows.forEach(function (row) { row.hidden = !all && row.getAttribute('data-selected') !== 'true'; });
      years.forEach(function (year) { year.hidden = !all; });
      filter.querySelectorAll('button[data-filter]').forEach(function (b) {
        b.setAttribute('aria-pressed', String(b.getAttribute('data-filter') === mode));
      });
      title.textContent = all ? 'Publications' : 'Selected Publications';
    };
    filter.hidden = false;
    filter.addEventListener('click', function (event) {
      var button = event.target.closest('button[data-filter]');
      if (button) show(button.getAttribute('data-filter'));
    });
  }

  // ---- news: Show older ----
  var more = document.querySelector('[data-show-older]');
  if (more) {
    more.hidden = false;
    more.addEventListener('click', function () {
      var revealed = document.querySelectorAll('[data-older]');
      revealed.forEach(function (el) { el.hidden = false; });
      var wrap = more.parentNode;
      wrap.parentNode.removeChild(wrap);
      // The button that held focus is now gone, so focus would fall back to
      // <body>. Move it to the first news item just revealed instead (some
      // [data-older] matches are year-group wrappers, not items).
      var first = null;
      for (var i = 0; i < revealed.length; i += 1) {
        if (revealed[i].classList.contains('n-item')) { first = revealed[i]; break; }
      }
      if (first) {
        first.setAttribute('tabindex', '-1');
        first.focus({ preventScroll: true });
      }
    });
  }
})();
