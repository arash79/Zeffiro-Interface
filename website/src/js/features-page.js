export function initFeatures() {
  document.documentElement.classList.add("js-feat");
  const chapters = [...document.querySelectorAll("[data-feat-chapter], .feat-continue, .feat-also")];
  const rail = document.querySelector("[data-feat-rail]");
  const reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  const mark = (el, on) => {
    el.classList.toggle("is-in", on);
  };

  if (reduced) {
    chapters.forEach((el) => mark(el, true));
  } else {
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) mark(entry.target, true);
        });
      },
      { threshold: 0.22, rootMargin: "0px 0px -8% 0px" },
    );
    chapters.forEach((el) => io.observe(el));
  }

  if (!rail) return;

  const links = [...rail.querySelectorAll("a[href^='#']")];
  const sections = links
    .map((link) => document.getElementById(link.getAttribute("href").slice(1)))
    .filter(Boolean);
  let current = "";
  let locked = false;
  let unlockTimer = 0;
  let pickRaf = 0;

  const setCurrent = (id) => {
    if (!id || id === current) return;
    current = id;
    links.forEach((link) => {
      const on = link.getAttribute("href") === `#${id}`;
      if (on) link.setAttribute("aria-current", "location");
      else link.removeAttribute("aria-current");
    });
  };

  const unlock = () => {
    locked = false;
    window.clearTimeout(unlockTimer);
  };

  const lockTo = (id) => {
    locked = true;
    setCurrent(id);
    window.clearTimeout(unlockTimer);
    unlockTimer = window.setTimeout(unlock, reduced ? 80 : 1100);
  };

  const idFromHash = () => {
    const id = decodeURIComponent(location.hash.replace(/^#/, ""));
    return sections.some((section) => section.id === id) ? id : "";
  };

  const coverage = (section) => {
    const rect = section.getBoundingClientRect();
    const vh = window.innerHeight || document.documentElement.clientHeight;
    const bandTop = vh * 0.2;
    const bandBottom = vh * 0.48;
    return Math.min(rect.bottom, bandBottom) - Math.max(rect.top, bandTop);
  };

  const pick = () => {
    if (locked || !sections.length) return;
    let bestId = "";
    let best = 0;
    sections.forEach((section) => {
      const visible = coverage(section);
      if (visible > best) {
        best = visible;
        bestId = section.id;
      }
    });
    if (!bestId || best < 12) return;
    const currentVis = current ? coverage(document.getElementById(current)) : 0;
    if (bestId === current || best >= currentVis + 16 || currentVis < 12) {
      setCurrent(bestId);
    }
  };

  const requestPick = () => {
    if (pickRaf) return;
    pickRaf = window.requestAnimationFrame(() => {
      pickRaf = 0;
      pick();
    });
  };

  const spy = new IntersectionObserver(requestPick, {
    threshold: [0, 0.1, 0.25, 0.5, 0.75, 1],
    rootMargin: "-18% 0px -50% 0px",
  });
  sections.forEach((section) => spy.observe(section));
  window.addEventListener("scroll", requestPick, { passive: true });

  const bootId = idFromHash();
  if (bootId) {
    lockTo(bootId);
    const bootTarget = document.getElementById(bootId);
    if (bootTarget) bootTarget.scrollIntoView({ behavior: "auto", block: "start" });
  } else if (sections[0]) {
    setCurrent(sections[0].id);
  }
  window.requestAnimationFrame(requestPick);

  rail.addEventListener("click", (event) => {
    const link = event.target.closest("a[href^='#']");
    if (!link || !rail.contains(link)) return;
    const id = link.getAttribute("href").slice(1);
    const target = document.getElementById(id);
    if (!target) return;
    event.preventDefault();
    lockTo(id);
    target.scrollIntoView({ behavior: reduced ? "auto" : "smooth", block: "start" });
    history.pushState(null, "", `#${id}`);
    const done = () => {
      window.removeEventListener("scrollend", done);
      unlock();
      requestPick();
    };
    window.addEventListener("scrollend", done, { once: true });
  });

  window.addEventListener("popstate", () => {
    const id = idFromHash();
    if (!id) return;
    const target = document.getElementById(id);
    if (!target) return;
    lockTo(id);
    target.scrollIntoView({ behavior: reduced ? "auto" : "smooth", block: "start" });
  });
}
