/* HAFIZ — Product landing page interactions */
(function () {
  'use strict';

  /* ── i18n ─────────────────────────────────────────────── */
  var I18N = {
    en: {
      hero_lede: 'Hafiz is an offline, fully-encrypted password vault for Android. No internet permission, no server, no telemetry — your passwords never leave this device.',
      hero_cta: 'Coming to Google Play',
      vault_lede: 'Everything is encrypted at rest and in memory. What you see here is the real Android app — captured from the release build.',
      features_lede: 'Fourteen features, all local, all private. No feature here depends on a server existing.',
      security_lede: 'Every byte of your vault is protected by the same primitives banks reach for — and nothing you care about ever leaves the device.',
      life_lede: 'Emergency access is the most carefully designed part of Hafiz. Someone you trust can unlock your vault after you\'re gone — completely offline, and only on your terms.',
      duress_lede: 'If you\'re forced to unlock your phone, you don\'t choose between safety and trust — you choose which truth you show.',
      move_lede: 'Your data is not a hostage. Hafiz can import the vaults you already use, and export encrypted backups only you can open.',
      pricing_lede: 'Every security feature is in both plans. The only difference is how many accounts you can keep.',
      pro_cta: 'Coming to Google Play',
      final_lede: 'Hafiz is built, tested, and awaiting its spot on Google Play. Join the waitlist and be first to know.',
      final_cta: 'Join the waitlist'
    },
    ar: {
      hero_lede: 'حافظ هو خزنة كلمات مرور مشفرة بالكامل وتعمل دون اتصال على أندرويد. لا إذن إنترنت، لا خادم، لا تتبع — كلمات مرورك لا تغادر جهازك أبدًا.',
      hero_cta: 'قريبًا على Google Play',
      vault_lede: 'كل شيء مشفّر عند التخزين وفي الذاكرة. ما تراه هنا هو تطبيق أندرويد الحقيقي — ملتقط من الإصدار النهائي.',
      features_lede: 'أربع عشرة ميزة، كلها محلية وخاصة. لا تعتمد أي ميزة على وجود خادم.',
      security_lede: 'كل بايت في خزنتك محمي بنفس الأدوات التي تستخدمها البنوك — ولا شيء يهمك يغادر جهازك أبدًا.',
      life_lede: 'الوصول الطارئ هو الجزء الأكثر تصميمًا بدقة في حافظ. شخص تثق به يستطيع فتح خزنتك بعد غيابك — دون اتصال وبشروطك أنت فقط.',
      duress_lede: 'إذا أُجبرت على فتح هاتفك، لا تختار بين الأمان والثقة — بل تختار أي الحقيقتين تُظهر.',
      move_lede: 'بياناتك ليست رهينة. يمكن لحافظ استيراد الخزائن التي تستخدمها بالفعل، وتصدير نسخ احتياطية مشفرة لا تفتحها إلا أنت.',
      pricing_lede: 'كل ميزات الأمان موجودة في الخطتين. الفرق الوحيد هو عدد الحسابات التي يمكنك الاحتفاظ بها.',
      pro_cta: 'قريبًا على Google Play',
      final_lede: 'حافظ مكتمل ومُختبَر، بانتظار مكانه على Google Play. انضم للقائمة ليصلك أول خبر.',
      final_cta: 'انضم للقائمة'
    }
  };

  var langBtn = document.getElementById('langToggle');
  var html = document.documentElement;

  function applyLang(lang) {
    var dict = I18N[lang] || I18N.en;
    Object.keys(dict).forEach(function (key) {
      var node = document.querySelector('[data-i18n="' + key + '"]');
      if (node) node.textContent = dict[key];
    });
    if (lang === 'ar') {
      html.lang = 'ar';
      html.dir = 'rtl';
    } else {
      html.lang = 'en';
      html.dir = 'ltr';
    }
    langBtn.textContent = lang === 'ar' ? 'EN' : 'ع';
    langBtn.setAttribute('aria-label', lang === 'ar' ? 'Switch language to English' : 'التبديل إلى العربية');
  }

  if (langBtn) {
    langBtn.addEventListener('click', function () {
      applyLang(html.lang === 'ar' ? 'en' : 'ar');
    });
  }

  /* ── Products dropdown ────────────────────────────────── */
  var pBtn = document.getElementById('productsBtn');
  var pMenu = document.getElementById('productsMenu');

  function closeProducts() {
    if (!pBtn || !pMenu) return;
    pBtn.setAttribute('aria-expanded', 'false');
    pMenu.hidden = true;
  }

  if (pBtn && pMenu) {
    pBtn.addEventListener('click', function (e) {
      e.stopPropagation();
      var open = pBtn.getAttribute('aria-expanded') === 'true';
      pBtn.setAttribute('aria-expanded', String(!open));
      pMenu.hidden = open;
    });
    pMenu.addEventListener('click', function (e) {
      if (e.target.closest('a')) closeProducts();
    });
    document.addEventListener('click', function (e) {
      if (!pMenu.hidden && !pMenu.contains(e.target) && e.target !== pBtn) closeProducts();
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && !pMenu.hidden) {
        closeProducts();
        pBtn.focus();
      }
    });
  }

  /* ── Animated counters ────────────────────────────────── */
  var counters = document.querySelectorAll('[data-count]');
  var fmtNum = function (el, v) {
    var target = parseInt(el.getAttribute('data-count'), 10) || 0;
    if (el.getAttribute('data-format') === 'k' && target === 100000) {
      return (v / 1000) + 'K';
    }
    return v.toLocaleString('en-US');
  };
  var animateCounter = function (el) {
    var target = parseInt(el.getAttribute('data-count'), 10) || 0;
    var duration = 1800;
    var start = performance.now();
    var tick = function (now) {
      var p = Math.min((now - start) / duration, 1);
      var eased = 1 - Math.pow(1 - p, 3);
      el.textContent = fmtNum(el, Math.round(target * eased));
      if (p < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  };
  if ('IntersectionObserver' in window) {
    var cio = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        animateCounter(entry.target);
        cio.unobserve(entry.target);
      });
    }, { threshold: 0.5 });
    counters.forEach(function (el) { cio.observe(el); });
  } else {
    counters.forEach(function (el) { el.textContent = fmtNum(el, parseInt(el.getAttribute('data-count'), 10) || 0); });
  }

  /* ── Showcase tilt on fine pointers ───────────────────── */
  var phones = document.querySelectorAll('.hafiz-showcase .hafiz-phone, .hafiz-phone--hero');
  if (window.matchMedia('(pointer: fine)').matches && phones.length) {
    phones.forEach(function (phone) {
      phone.addEventListener('mousemove', function (e) {
        var r = phone.getBoundingClientRect();
        var px = (e.clientX - r.left) / r.width - 0.5;
        var py = (e.clientY - r.top) / r.height - 0.5;
        phone.style.transform = 'perspective(1100px) rotateY(' + (px * 7).toFixed(2) + 'deg) rotateX(' + (-py * 7).toFixed(2) + 'deg)';
      });
      phone.addEventListener('mouseleave', function () {
        phone.style.transform = '';
      });
    });
  }

  /* ── Smooth anchor scroll (respect reduced-motion) ────── */
  var prefersReduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  document.querySelectorAll('a[href^="#"]').forEach(function (a) {
    a.addEventListener('click', function (e) {
      var id = a.getAttribute('href');
      if (id.length < 2) return;
      var target = document.querySelector(id);
      if (!target) return;
      e.preventDefault();
      var y = target.getBoundingClientRect().top + window.scrollY - 72;
      window.scrollTo({ top: y, behavior: prefersReduce ? 'auto' : 'smooth' });
    });
  });

  /* ── Preload fonts hint (matters on slow connections) ─── */
  if ('fonts' in document) {
    document.fonts.load('16px "Space Grotesk"');
    document.fonts.load('16px "JetBrains Mono Local"');
  }
})();