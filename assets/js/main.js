/* ============================================================
   Salvation Security Agency Inc. — homepage behavior
   Vanilla JS, no dependencies.
   ============================================================ */
(function () {
  'use strict';

  /* ---------- Sticky header shadow ---------- */
  var header = document.querySelector('[data-header]');
  function onScroll() {
    if (header) header.classList.toggle('is-scrolled', window.scrollY > 8);
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  /* ---------- Mobile navigation ---------- */
  var toggle = document.querySelector('[data-nav-toggle]');
  var nav = document.querySelector('[data-nav]');

  function closeNav() {
    if (!toggle || !nav) return;
    toggle.setAttribute('aria-expanded', 'false');
    nav.classList.remove('is-open');
  }

  if (toggle && nav) {
    toggle.addEventListener('click', function () {
      var open = toggle.getAttribute('aria-expanded') === 'true';
      toggle.setAttribute('aria-expanded', String(!open));
      nav.classList.toggle('is-open', !open);
    });

    // Close when a link is chosen or Escape is pressed
    nav.addEventListener('click', function (e) {
      if (e.target.closest('a')) closeNav();
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') closeNav();
    });
  }

  /* ---------- FAQ: keep one item open at a time ---------- */
  var faqItems = document.querySelectorAll('.faq__item');
  faqItems.forEach(function (item) {
    item.addEventListener('toggle', function () {
      if (!item.open) return;
      faqItems.forEach(function (other) {
        if (other !== item) other.open = false;
      });
    });
  });

  /* ---------- Inquiry form validation ----------
     NOTE: no backend endpoint is configured yet (the agency has not
     published an email/inquiry endpoint). Until one is connected,
     a validated submission shows the verified phone / Facebook
     contact instead of a fake success message. */
  var form = document.querySelector('[data-form]');
  var status = document.querySelector('[data-form-status]');

  function getErrorEl(input) {
    var describedBy = (input.getAttribute('aria-describedby') || '').split(/\s+/);
    for (var i = 0; i < describedBy.length; i++) {
      var el = document.getElementById(describedBy[i]);
      if (el && el.classList.contains('field__error')) return el;
    }
    return null;
  }

  function setError(input, errorEl, hasError) {
    input.setAttribute('aria-invalid', hasError ? 'true' : 'false');
    if (errorEl) errorEl.hidden = !hasError;
  }

  function validateField(input) {
    var errorEl = getErrorEl(input);
    var value = (input.value || '').trim();
    var invalid = false;

    if (input.id === 'cf-name') {
      invalid = value.length < 2;
    } else if (input.id === 'cf-phone') {
      // Accepts digits, spaces, parentheses, hyphens, plus; 7-16 digits total
      var digits = value.replace(/\D/g, '');
      invalid = !/^[+(\d][\d\s().-]{6,19}$/.test(value) || digits.length < 7 || digits.length > 16;
    } else if (input.id === 'cf-service') {
      invalid = !value;
    } else if (input.id === 'cf-message') {
      invalid = value.length < 10;
    }

    setError(input, errorEl, invalid);
    return !invalid;
  }

  if (form) {
    var inputs = form.querySelectorAll('input[name], select[name], textarea[name]');
    inputs.forEach(function (input) {
      input.addEventListener('blur', function () {
        if (input.name !== 'website') validateField(input); // skip honeypot
      });
      input.addEventListener('input', function () {
        if (input.getAttribute('aria-invalid') === 'true') validateField(input);
      });
    });

    form.addEventListener('submit', function (e) {
      e.preventDefault();

      // Honeypot: pretend success for bots
      var hp = form.querySelector('#cf-website');
      if (hp && hp.value) {
        if (status) {
          status.textContent = 'Thank you.';
          status.className = 'contact-form__status is-visible is-ok';
        }
        form.reset();
        return;
      }

      var allValid = true;
      var firstInvalid = null;
      inputs.forEach(function (input) {
        if (input.name === 'website') return;
        var ok = validateField(input);
        if (!ok && !firstInvalid) firstInvalid = input;
        allValid = allValid && ok;
      });

      if (status) {
        status.classList.remove('is-visible', 'is-ok', 'is-error');
      }

      if (!allValid) {
        if (status) {
          status.textContent = 'Please complete the highlighted fields.';
          status.classList.add('is-visible', 'is-error');
        }
        if (firstInvalid) firstInvalid.focus();
        return;
      }

      // Valid submission — no endpoint connected yet: direct to verified channels.
      if (status) {
        status.innerHTML =
          'Thank you, <strong>' +
          form.querySelector('#cf-name').value.trim().split(/\s+/)[0].replace(/[<>&"]/g, '') +
          '</strong>! Your details are validated and ready. To submit your inquiry right away, ' +
          'call <a href="tel:+63456080518">(045) 608 0518</a> or message our ' +
          '<a href="https://www.facebook.com/salvationsecurityagencyinc" target="_blank" rel="noopener">Facebook page</a>.';
        status.classList.add('is-visible', 'is-ok');
      }
      // TODO: POST the form data to the agency's inquiry endpoint once available.
    });
  }

  /* ---------- Footer year ---------- */
  var yearEl = document.querySelector('[data-year]');
  if (yearEl) yearEl.textContent = String(new Date().getFullYear());

  /* ---------- Scroll reveal (respects reduced motion) ---------- */
  var reveals = document.querySelectorAll('.reveal');
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  // Inside an iframe/embed, intersection observers track the host scroll — reveal immediately.
  var embedded = (function () { try { return window.self !== window.top; } catch (e) { return true; } })();

  if (reveals.length && 'IntersectionObserver' in window && !reduceMotion && !embedded) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
    reveals.forEach(function (el) { io.observe(el); });
  } else {
    reveals.forEach(function (el) { el.classList.add('is-visible'); });
  }
})();
