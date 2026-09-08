const clamp01 = (value) => Math.min(1, Math.max(0, value));

export function initScenes() {
  const scenes = [...document.querySelectorAll("[data-scene]")];
  if (!scenes.length) return;

  const motion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const params = new URLSearchParams(window.location.search);
  const qa = params.has("qa");
  const requested = Number.parseInt(params.get("scene") || "1", 10);

  const reset = () => {
    document.documentElement.classList.remove("js-scenes", "js-ready", "is-scrolling");
    scenes.forEach((scene) => {
      scene.style.setProperty("--clarity", "1");
      scene.classList.add("is-active", "is-sharp");
      scene.classList.remove("is-far");
    });
  };

  const goRequested = () => {
    if (params.get("at") === "mid") return;
    if (requested > 1 && scenes[requested - 1]) {
      scenes[requested - 1].scrollIntoView({ behavior: "instant", block: "start" });
    }
  };

  if (qa || motion.matches || params.get("at") === "mid") {
    if (qa || motion.matches) reset();
    goRequested();
    return;
  }

  document.documentElement.classList.add("js-scenes");

  let ticking = false;
  let idleTimer = 0;

  const update = () => {
    const vh = window.innerHeight || 1;
    scenes.forEach((scene) => {
      const rect = scene.getBoundingClientRect();
      const visible = Math.min(rect.bottom, vh) - Math.max(rect.top, 0);
      const occupancy = clamp01(visible / vh);
      scene.style.setProperty("--clarity", occupancy.toFixed(4));
      scene.classList.toggle("is-far", occupancy <= 0.001);
      scene.classList.toggle("is-active", occupancy > 0.18);
      scene.classList.toggle("is-sharp", occupancy > 0.96);
    });
    ticking = false;
  };

  const onScroll = () => {
    if (!ticking) {
      ticking = true;
      requestAnimationFrame(update);
    }
    document.documentElement.classList.add("is-scrolling");
    window.clearTimeout(idleTimer);
    idleTimer = window.setTimeout(() => {
      document.documentElement.classList.remove("is-scrolling");
    }, 160);
  };

  window.addEventListener("scroll", onScroll, { passive: true });
  window.addEventListener("resize", onScroll, { passive: true });
  window.addEventListener("orientationchange", onScroll, { passive: true });
  window.addEventListener("pageshow", () => requestAnimationFrame(update));
  window.addEventListener("scrollend", update, { passive: true });
  motion.addEventListener("change", () => window.location.reload());

  goRequested();
  update();
  requestAnimationFrame(() => {
    update();
    requestAnimationFrame(update);
  });
}
