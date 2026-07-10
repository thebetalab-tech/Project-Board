/* ==========================================================================
   PROJECT BOARD — LANDING PAGE SCRIPTS
   GSAP + ScrollTrigger + Lenis smooth scroll
   ========================================================================== */

(() => {
  'use strict';

  // ========================================================================
  // 0. FEATURE DETECTION & PREFERENCES
  // ========================================================================
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const isTouchDevice = window.matchMedia('(pointer: coarse)').matches;
  const isMobile = window.innerWidth <= 768;

  // Register GSAP plugins
  gsap.registerPlugin(ScrollTrigger);

  // ========================================================================
  // 1. SMOOTH SCROLLING (Lenis)
  // ========================================================================
  let lenis;

  function initLenis() {
    if (prefersReducedMotion) return;

    lenis = new Lenis({
      duration: 1.2,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      orientation: 'vertical',
      gestureOrientation: 'vertical',
      smoothWheel: true,
      wheelMultiplier: 1,
      touchMultiplier: 2,
    });

    // Connect Lenis to GSAP ScrollTrigger
    lenis.on('scroll', ScrollTrigger.update);
    gsap.ticker.add((time) => lenis.raf(time * 1000));
    gsap.ticker.lagSmoothing(0);
  }

  // ========================================================================
  // 2. CUSTOM CURSOR (REMOVED)
  // ========================================================================
  function initCursor() {
    // Cursor removed by user request
  }

  // ========================================================================
  // 3. MAGNETIC BUTTONS
  // ========================================================================
  function initMagneticButtons() {
    if (isTouchDevice || prefersReducedMotion) return;

    const magneticEls = document.querySelectorAll('[data-magnetic]');

    magneticEls.forEach((el) => {
      el.addEventListener('mousemove', (e) => {
        const rect = el.getBoundingClientRect();
        const x = e.clientX - rect.left - rect.width / 2;
        const y = e.clientY - rect.top - rect.height / 2;
        const strength = 0.3;

        gsap.to(el, {
          x: x * strength,
          y: y * strength,
          duration: 0.4,
          ease: 'power2.out',
        });
      });

      el.addEventListener('mouseleave', () => {
        gsap.to(el, {
          x: 0,
          y: 0,
          duration: 0.6,
          ease: 'elastic.out(1, 0.4)',
        });
      });
    });
  }

  // ========================================================================
  // 4. LOADER / INTRO ANIMATION
  // ========================================================================
  function initLoader() {
    const loader = document.getElementById('loader');
    const words = loader.querySelectorAll('.loader__word');
    const barFill = loader.querySelector('.loader__bar-fill');

    document.body.classList.add('is-loading');

    const tl = gsap.timeline({
      onComplete: () => {
        // Reveal page
        gsap.to(loader, {
          opacity: 0,
          duration: 0.6,
          ease: 'power2.inOut',
          onComplete: () => {
            loader.classList.add('is-hidden');
            loader.style.display = 'none';
            document.body.classList.remove('is-loading');
            // Start page animations
            animateHero();
          },
        });
      },
    });

    if (prefersReducedMotion) {
      // Skip loader immediately
      loader.style.display = 'none';
      document.body.classList.remove('is-loading');
      // Show all anim-text and anim-line immediately
      document.querySelectorAll('.anim-text').forEach(el => {
        el.style.opacity = '1';
        el.style.transform = 'none';
      });
      document.querySelectorAll('.anim-line').forEach(el => {
        el.style.transform = 'none';
      });
      document.querySelectorAll('.anim-card').forEach(el => {
        el.style.opacity = '1';
        el.style.transform = 'none';
      });
      return;
    }

    // Letter stagger
    tl.to(words, {
      opacity: 1,
      y: 0,
      duration: 0.5,
      stagger: 0.04,
      ease: 'power3.out',
    }, 0.3);

    // Bar fill
    tl.to(barFill, {
      width: '100%',
      duration: 1.2,
      ease: 'power2.inOut',
    }, 0.6);

    // Hold for a moment
    tl.to({}, { duration: 0.3 });
  }

  // ========================================================================
  // 5. HERO SECTION ANIMATIONS
  // ========================================================================
  function animateHero() {
    if (prefersReducedMotion) return;

    const tl = gsap.timeline({ defaults: { ease: 'power3.out' } });

    // Lines reveal
    tl.to('.hero .anim-line', {
      y: 0,
      duration: 1,
      stagger: 0.12,
    }, 0);

    // Text elements
    tl.to('.hero .anim-text', {
      opacity: 1,
      y: 0,
      duration: 0.8,
      stagger: 0.1,
    }, 0.4);

    // Nav
    tl.from('.nav', {
      y: -40,
      opacity: 0,
      duration: 0.8,
    }, 0.6);
  }

  // ========================================================================
  // 6. HERO CANVAS — Subtle grid + floating particles
  // ========================================================================
  function initHeroCanvas() {
    const canvas = document.getElementById('heroCanvas');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    let animId;
    let particles = [];
    const PARTICLE_COUNT = isMobile ? 30 : 60;

    function resize() {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    }
    resize();
    window.addEventListener('resize', resize);

    // Create particles
    for (let i = 0; i < PARTICLE_COUNT; i++) {
      particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        radius: Math.random() * 1.5 + 0.5,
        vx: (Math.random() - 0.5) * 0.3,
        vy: (Math.random() - 0.5) * 0.3,
        opacity: Math.random() * 0.3 + 0.1,
      });
    }

    function drawGrid() {
      const gridSize = 60;
      ctx.strokeStyle = 'rgba(0, 0, 0, 0.03)';
      ctx.lineWidth = 0.5;

      for (let x = 0; x < canvas.width; x += gridSize) {
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, canvas.height);
        ctx.stroke();
      }
      for (let y = 0; y < canvas.height; y += gridSize) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(canvas.width, y);
        ctx.stroke();
      }
    }

    function drawParticles() {
      particles.forEach((p) => {
        p.x += p.vx;
        p.y += p.vy;

        // Wrap around
        if (p.x < 0) p.x = canvas.width;
        if (p.x > canvas.width) p.x = 0;
        if (p.y < 0) p.y = canvas.height;
        if (p.y > canvas.height) p.y = 0;

        ctx.beginPath();
        ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(123, 30, 45, ${p.opacity * 0.6})`;
        ctx.fill();
      });

      // Draw connections between nearby particles
      for (let i = 0; i < particles.length; i++) {
        for (let j = i + 1; j < particles.length; j++) {
          const dx = particles[i].x - particles[j].x;
          const dy = particles[i].y - particles[j].y;
          const dist = Math.sqrt(dx * dx + dy * dy);

          if (dist < 120) {
            ctx.beginPath();
            ctx.moveTo(particles[i].x, particles[i].y);
            ctx.lineTo(particles[j].x, particles[j].y);
            ctx.strokeStyle = `rgba(123, 30, 45, ${0.04 * (1 - dist / 120)})`;
            ctx.lineWidth = 0.5;
            ctx.stroke();
          }
        }
      }
    }

    function animate() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      drawGrid();
      drawParticles();
      animId = requestAnimationFrame(animate);
    }

    if (!prefersReducedMotion) {
      animate();
    } else {
      // Just draw static grid
      drawGrid();
    }

    // Clean up when scrolled past hero
    ScrollTrigger.create({
      trigger: '.hero',
      start: 'bottom top',
      onEnterBack: () => { if (!prefersReducedMotion) animate(); },
      onLeave: () => cancelAnimationFrame(animId),
    });
  }

  // ========================================================================
  // 7. SCROLL-TRIGGERED TEXT ANIMATIONS
  // ========================================================================
  function initScrollAnimations() {
    if (prefersReducedMotion) return;

    // Animate .anim-line elements (headline reveals)
    const lineWraps = document.querySelectorAll('section:not(.hero) .anim-line');
    lineWraps.forEach((line) => {
      gsap.to(line, {
        y: 0,
        duration: 0.9,
        ease: 'power3.out',
        scrollTrigger: {
          trigger: line.closest('.line-wrap'),
          start: 'top 85%',
          toggleActions: 'play none none none',
        },
      });
    });

    // Animate .anim-text elements (fade-up)
    const animTexts = document.querySelectorAll('section:not(.hero) .anim-text');
    animTexts.forEach((el) => {
      gsap.to(el, {
        opacity: 1,
        y: 0,
        duration: 0.8,
        ease: 'power3.out',
        scrollTrigger: {
          trigger: el,
          start: 'top 88%',
          toggleActions: 'play none none none',
        },
      });
    });

    // Animate .anim-card elements (cards reveal)
    const animCards = document.querySelectorAll('.anim-card');
    animCards.forEach((card, i) => {
      gsap.to(card, {
        opacity: 1,
        y: 0,
        duration: 0.8,
        delay: (i % 3) * 0.12, // stagger within groups
        ease: 'power3.out',
        scrollTrigger: {
          trigger: card,
          start: 'top 88%',
          toggleActions: 'play none none none',
        },
      });
    });
  }

  // ========================================================================
  // 8. HORIZONTAL SCROLL — "How It Works" Section
  // ========================================================================
  function initHorizontalScroll() {
    if (isMobile || prefersReducedMotion) return;

    const section = document.querySelector('.how');
    const sticky = document.querySelector('.how__sticky');
    const track = document.getElementById('howTrack');
    const progressBar = document.getElementById('howProgressBar');

    if (!section || !track) return;

    // Make sticky full viewport
    sticky.style.height = '100vh';
    sticky.style.display = 'flex';
    sticky.style.flexDirection = 'column';

    const steps = track.querySelectorAll('.how__step');
    const totalScrollWidth = (steps.length * (340 + 32)) - window.innerWidth + 200;

    gsap.to(track, {
      x: () => -totalScrollWidth,
      ease: 'none',
      scrollTrigger: {
        trigger: section,
        start: 'top top',
        end: () => `+=${totalScrollWidth}`,
        pin: sticky,
        scrub: 1,
        invalidateOnRefresh: true,
        onUpdate: (self) => {
          if (progressBar) {
            progressBar.style.width = `${self.progress * 100}%`;
          }
        },
      },
    });
  }

  // ========================================================================
  // 9. NUMBER COUNTER ANIMATION
  // ========================================================================
  function initCounters() {
    const counters = document.querySelectorAll('.stat__number[data-count]');

    counters.forEach((counter) => {
      const target = parseInt(counter.dataset.count, 10);

      ScrollTrigger.create({
        trigger: counter,
        start: 'top 85%',
        once: true,
        onEnter: () => {
          if (prefersReducedMotion) {
            counter.textContent = target;
            return;
          }

          gsap.to({ val: 0 }, {
            val: target,
            duration: 2,
            ease: 'power2.out',
            onUpdate: function () {
              counter.textContent = Math.round(this.targets()[0].val);
            },
          });
        },
      });
    });
  }

  // ========================================================================
  // 10. INTERACTIVE DUPLICATE DETECTION DEMO
  // ========================================================================
  function initDuplicateDemo() {
    const input = document.getElementById('demoInput');
    const btn = document.getElementById('demoBtn');
    if (!input) return;

    function handleSearch() {
      const query = input.value.trim();
      if (query) {
        window.location.href = 'results.html?q=' + encodeURIComponent(query);
      }
    }

    if (btn) {
      btn.addEventListener('click', handleSearch);
    }

    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') {
        e.preventDefault();
        handleSearch();
      }
    });
  }

  // ========================================================================
  // 11. NAVIGATION — Scroll State & Mobile Menu
  // ========================================================================
  function initNavigation() {
    const nav = document.getElementById('nav');
    const burger = document.getElementById('navBurger');
    const mobileMenu = document.getElementById('mobileMenu');
    const mobileLinks = mobileMenu.querySelectorAll('.mobile-menu__link');

    // Scroll state
    ScrollTrigger.create({
      start: 80,
      onUpdate: (self) => {
        if (self.scroll() > 80) {
          nav.classList.add('is-scrolled');
        } else {
          nav.classList.remove('is-scrolled');
        }
      },
    });

    // Mobile menu toggle
    burger.addEventListener('click', () => {
      const isOpen = mobileMenu.classList.contains('is-open');
      burger.classList.toggle('is-active');
      burger.setAttribute('aria-expanded', !isOpen);
      mobileMenu.classList.toggle('is-open');
      mobileMenu.setAttribute('aria-hidden', isOpen);

      if (!isOpen) {
        document.body.style.overflow = 'hidden';
      } else {
        document.body.style.overflow = '';
      }
    });

    // Close on link click
    mobileLinks.forEach((link) => {
      link.addEventListener('click', () => {
        burger.classList.remove('is-active');
        burger.setAttribute('aria-expanded', 'false');
        mobileMenu.classList.remove('is-open');
        mobileMenu.setAttribute('aria-hidden', 'true');
        document.body.style.overflow = '';
      });
    });

    // Smooth anchor scrolling
    document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
      anchor.addEventListener('click', (e) => {
        e.preventDefault();
        const target = document.querySelector(anchor.getAttribute('href'));
        if (!target) return;

        if (lenis) {
          lenis.scrollTo(target, { offset: 0, duration: 1.5 });
        } else {
          target.scrollIntoView({ behavior: 'smooth' });
        }
      });
    });
  }

  // ========================================================================
  // 12. PARALLAX EFFECTS
  // ========================================================================
  function initParallax() {
    if (prefersReducedMotion || isMobile) return;

    // Problem cards subtle parallax
    gsap.to('.problem__card--left', {
      y: -30,
      scrollTrigger: {
        trigger: '.problem__visual',
        start: 'top bottom',
        end: 'bottom top',
        scrub: 1,
      },
    });

    gsap.to('.problem__card--right', {
      y: 30,
      scrollTrigger: {
        trigger: '.problem__visual',
        start: 'top bottom',
        end: 'bottom top',
        scrub: 1,
      },
    });

    // Detection layers stagger
    document.querySelectorAll('.detection__layer').forEach((layer, i) => {
      gsap.from(layer, {
        x: i % 2 === 0 ? -30 : 30,
        opacity: 0,
        duration: 0.8,
        ease: 'power3.out',
        scrollTrigger: {
          trigger: layer,
          start: 'top 85%',
          toggleActions: 'play none none none',
        },
      });
    });
  }

  // ========================================================================
  // 13. CTA SECTION ANIMATION
  // ========================================================================
  function initCTAAnimation() {
    if (prefersReducedMotion) return;

    const section = document.querySelector('.cta-section');
    if (!section) return;

    gsap.from(section, {
      backgroundPosition: '0% 0%',
      scrollTrigger: {
        trigger: section,
        start: 'top bottom',
        end: 'bottom top',
        scrub: 1,
      },
    });
  }

  // ========================================================================
  // 14. DETECTION LAYER GLOW ANIMATION
  // ========================================================================
  function initLayerGlow() {
    if (prefersReducedMotion) return;

    const layers = document.querySelectorAll('.detection__layer');
    layers.forEach((layer, i) => {
      ScrollTrigger.create({
        trigger: layer,
        start: 'top 60%',
        end: 'bottom 40%',
        onEnter: () => {
          gsap.to(layer, {
            borderColor: 'rgba(123, 30, 45, 0.4)',
            boxShadow: '0 0 30px rgba(123, 30, 45, 0.08)',
            duration: 0.6,
          });
        },
        onLeave: () => {
          gsap.to(layer, {
            borderColor: 'rgba(0, 0, 0, 0.08)',
            boxShadow: 'none',
            duration: 0.6,
          });
        },
        onEnterBack: () => {
          gsap.to(layer, {
            borderColor: 'rgba(123, 30, 45, 0.4)',
            boxShadow: '0 0 30px rgba(123, 30, 45, 0.08)',
            duration: 0.6,
          });
        },
        onLeaveBack: () => {
          gsap.to(layer, {
            borderColor: 'rgba(0, 0, 0, 0.08)',
            boxShadow: 'none',
            duration: 0.6,
          });
        },
      });
    });
  }

  // ========================================================================
  // 15. TEAM CARDS HOVER TILT
  // ========================================================================
  function initCardTilt() {
    if (isTouchDevice || prefersReducedMotion) return;

    const cards = document.querySelectorAll('.team-card, .role-card');

    cards.forEach((card) => {
      card.addEventListener('mousemove', (e) => {
        const rect = card.getBoundingClientRect();
        const x = (e.clientX - rect.left) / rect.width - 0.5;
        const y = (e.clientY - rect.top) / rect.height - 0.5;

        gsap.to(card, {
          rotateY: x * 8,
          rotateX: -y * 8,
          duration: 0.4,
          ease: 'power2.out',
          transformPerspective: 800,
        });
      });

      card.addEventListener('mouseleave', () => {
        gsap.to(card, {
          rotateY: 0,
          rotateX: 0,
          duration: 0.6,
          ease: 'elastic.out(1, 0.5)',
        });
      });
    });
  }

  // ========================================================================
  // 16. ANIMATED UNDERLINES ON NAV LINKS (Active Section Tracking)
  // ========================================================================
  function initActiveSection() {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav__link');

    sections.forEach((section) => {
      ScrollTrigger.create({
        trigger: section,
        start: 'top 50%',
        end: 'bottom 50%',
        onEnter: () => setActiveLink(section.id),
        onEnterBack: () => setActiveLink(section.id),
      });
    });

    function setActiveLink(sectionId) {
      navLinks.forEach((link) => {
        const href = link.getAttribute('href').replace('#', '');
        if (href === sectionId) {
          link.style.color = 'var(--c-text)';
          link.querySelector('::after')?.style;
        } else {
          link.style.color = '';
        }
      });
    }
  }

  // ========================================================================
  // 17. LIQUID GLASS ANIMATION (REMOVED)
  // ========================================================================
  function initLiquidGlass() {
    // Liquid glass removed by user request
  }

  // ========================================================================
  // INIT — Orchestrate everything
  // ========================================================================
  function init() {
    initLenis();
    initCursor();
    initMagneticButtons();
    initLoader();
    initHeroCanvas();
    initNavigation();

    // Scroll-based animations — wait a tick for layout
    requestAnimationFrame(() => {
      initScrollAnimations();
      initHorizontalScroll();
      initCounters();
      initParallax();
      initLayerGlow();
      initCTAAnimation();
      initCardTilt();
      initActiveSection();
      initLiquidGlass();
    });

    initDuplicateDemo();
  }

  // Run when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
