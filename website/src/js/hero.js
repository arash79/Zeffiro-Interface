const STATES = [
  { id: "anatomy", src: "assets/img/hero-head.webp", label: "Anatomy" },
  { id: "mesh", src: "assets/img/hero-mesh.webp", label: "Mesh" },
  { id: "electrodes", src: "assets/img/hero-electrodes.webp", label: "Electrodes" },
  { id: "sources", src: "assets/img/hero-sources.webp", label: "Sources" },
];

export function initHero() {
  const stage = document.querySelector("[data-hero-stage]");
  const visual = document.querySelector("[data-hero-visual]");
  if (!stage || !visual) return;

  const buttons = [...document.querySelectorAll("[data-hero-step]")];
  const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  let index = 0;

  const setState = (next) => {
    index = next;
    visual.dataset.state = STATES[index].id;
    visual.querySelectorAll("img[data-hero-layer]").forEach((img, i) => {
      img.classList.toggle("is-active", i === index);
    });
    buttons.forEach((btn, i) => {
      const active = i === index;
      btn.classList.toggle("is-active", active);
      btn.setAttribute("aria-current", active ? "true" : "false");
    });
  };

  buttons.forEach((btn, i) => {
    btn.addEventListener("click", () => setState(i));
  });

  if (!reduce) {
    stage.addEventListener("pointermove", (event) => {
      const rect = stage.getBoundingClientRect();
      const x = (event.clientX - rect.left) / rect.width - 0.5;
      const y = (event.clientY - rect.top) / rect.height - 0.5;
      visual.style.transform = `rotateY(${x * 10}deg) rotateX(${-y * 6}deg) translateZ(12px)`;
    });
    stage.addEventListener("pointerleave", () => {
      visual.style.transform = "";
    });
  }

  stage.addEventListener("keydown", (event) => {
    if (event.key === "ArrowDown" || event.key === "ArrowRight") {
      event.preventDefault();
      setState((index + 1) % STATES.length);
    }
    if (event.key === "ArrowUp" || event.key === "ArrowLeft") {
      event.preventDefault();
      setState((index - 1 + STATES.length) % STATES.length);
    }
  });

  setState(0);
}
