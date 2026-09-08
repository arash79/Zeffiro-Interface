import { docsBySlug, docsNav, landing } from "./docs-catalog.js";
import { renderMarkdown, typesetMath } from "./markdown.js";

const cache = new Map();
let searchIndex = null;

function parseHash() {
  const raw = (location.hash || "#").replace(/^#/, "");
  if (!raw) return { slug: "", heading: "" };
  const [slug, ...rest] = raw.split("/");
  return { slug, heading: rest.join("/") };
}

function excerptAround(text, query) {
  const lower = text.toLowerCase();
  const idx = lower.indexOf(query);
  if (idx < 0) return "";
  const start = Math.max(0, idx - 36);
  const chunk = text.slice(start, idx + query.length + 72).replace(/\s+/g, " ").trim();
  return (start > 0 ? "…" : "") + chunk + (idx + query.length + 72 < text.length ? "…" : "");
}

async function loadDoc(slug) {
  if (cache.has(slug)) return cache.get(slug);
  const meta = docsBySlug[slug];
  if (!meta) throw new Error("Unknown document");
  const res = await fetch(new URL(`content/docs/${meta.file}`, document.baseURI));
  if (!res.ok) throw new Error("Missing document");
  const md = await res.text();
  const rendered = renderMarkdown(md, { slug });
  const entry = { ...meta, md, ...rendered };
  cache.set(slug, entry);
  return entry;
}

async function ensureSearchIndex() {
  if (searchIndex) return searchIndex;
  const slugs = Object.keys(docsBySlug);
  const entries = await Promise.all(
    slugs.map(async (slug) => {
      try {
        const doc = await loadDoc(slug);
        const headings = (doc.toc || []).map((item) => item.text).join(" ");
        return {
          slug,
          title: doc.title,
          headings,
          text: doc.md,
        };
      } catch {
        return { slug, title: docsBySlug[slug].title, headings: "", text: "" };
      }
    }),
  );
  searchIndex = entries;
  return searchIndex;
}

function searchDocs(query) {
  const q = query.trim().toLowerCase();
  if (q.length < 2) return [];
  return searchIndex
    .map((entry) => {
      const titleHit = entry.title.toLowerCase().includes(q);
      const headingHit = entry.headings.toLowerCase().includes(q);
      const bodyHit = entry.text.toLowerCase().includes(q);
      if (!titleHit && !headingHit && !bodyHit) return null;
      const snippet =
        excerptAround(entry.title, q) ||
        excerptAround(entry.headings, q) ||
        excerptAround(entry.text.replace(/[#*`|]/g, " "), q);
      return {
        slug: entry.slug,
        title: entry.title,
        snippet,
        score: titleHit ? 3 : headingHit ? 2 : 1,
      };
    })
    .filter(Boolean)
    .sort((a, b) => b.score - a.score || a.title.localeCompare(b.title))
    .slice(0, 8);
}

function navHTML(active) {
  return docsNav
    .map((group) => {
      const links = group.items
        .map((item) => {
          const current = item.slug === active ? ' aria-current="page"' : "";
          return `<a class="docs-link" href="#${item.slug}"${current}>${item.title}</a>`;
        })
        .join("");
      return `<div class="docs-group"><p class="docs-group-label">${group.label}</p>${links}</div>`;
    })
    .join("");
}

function setToc(html) {
  const toc = document.querySelector("[data-docs-toc]");
  const shell = document.querySelector(".docs-shell");
  const markup = html || "";
  if (toc) toc.innerHTML = markup;
  if (shell) shell.classList.toggle("has-toc", Boolean(markup));
}

function tocHTML(toc, slug) {
  if (!toc.length) return "";
  return `<p class="docs-toc-label">On this page</p>${toc
    .map(
      (item) =>
        `<a class="docs-toc-link" href="#${slug}/${item.id}" data-level="${item.level}">${item.text}</a>`,
    )
    .join("")}`;
}

function landingHTML() {
  const start = landing.start
    .map(
      (card) => `
      <a class="docs-start-card" href="#${card.slug}">
        <span class="docs-start-kicker">${card.kicker}</span>
        <strong>${card.title}</strong>
        <span>${card.text}</span>
      </a>`,
    )
    .join("");
  const path = landing.path
    .map((step, i) => {
      const href = step.hash ? `#${step.slug}/${step.hash}` : `#${step.slug}`;
      const arrow =
        i < landing.path.length - 1 ? '<span class="docs-path-arrow" aria-hidden="true"></span>' : "";
      return `<a class="docs-path-step" href="${href}">${step.label}</a>${arrow}`;
    })
    .join("");
  const tasks = landing.tasks
    .map((task) => {
      const href = task.hash ? `#${task.slug}/${task.hash}` : `#${task.slug}`;
      return `<a class="docs-task" href="${href}">${task.title}</a>`;
    })
    .join("");
  return `
    <article class="docs-article docs-landing-copy">
      <p class="kicker">Documentation</p>
      <h1>Start a session.<br /><span class="grad-text">Then read the maps.</span></h1>
      <p class="docs-lede">${landing.lede}</p>
      <div class="docs-path" aria-label="Core workflow">${path}</div>
      <h2>Start here</h2>
      <div class="docs-start-grid">${start}</div>
      <h2>Common tasks</h2>
      <div class="docs-task-row">${tasks}</div>
      <div class="docs-also">
        <p>Changing code? <a href="#architecture">Architecture</a> and the <a href="#developer-guide">developer guide</a> are the maps for the tree. Layout decisions live under Decisions.</p>
        <p>GUI click-paths that exist only on the GitHub wiki remain on <a href="tutorials.html">Tutorials</a>. Source stays on GitHub.</p>
      </div>
    </article>
  `;
}

function highlightNav(slug) {
  document.querySelectorAll(".docs-link").forEach((link) => {
    const current = link.getAttribute("href") === `#${slug}`;
    if (current) link.setAttribute("aria-current", "page");
    else link.removeAttribute("aria-current");
  });
}

function setSidebarOpen(open) {
  const page = document.querySelector(".docs-page");
  const toggle = document.querySelector("[data-docs-open]");
  if (!page) return;
  page.classList.toggle("is-nav-open", open);
  if (toggle) {
    toggle.setAttribute("aria-expanded", String(open));
    toggle.setAttribute("aria-label", open ? "Close documentation menu" : "Open documentation menu");
  }
}

function bindTocSpy() {
  const links = [...document.querySelectorAll(".docs-toc-link")];
  if (!links.length) return;
  const headings = links
    .map((link) => {
      const id = link.getAttribute("href")?.split("/")[1];
      return id ? document.getElementById(id) : null;
    })
    .filter(Boolean);
  if (!headings.length) return;
  const observer = new IntersectionObserver(
    (entries) => {
      const visible = entries
        .filter((entry) => entry.isIntersecting)
        .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
      const id = (visible[0] || entries[0]).target.id;
      links.forEach((link) => {
        const current = link.getAttribute("href")?.endsWith(`/${id}`);
        if (current) link.setAttribute("aria-current", "location");
        else link.removeAttribute("aria-current");
      });
    },
    { rootMargin: "-20% 0px -70% 0px", threshold: [0, 1] },
  );
  headings.forEach((el) => observer.observe(el));
}

async function render() {
  const { slug, heading } = parseHash();
  const article = document.querySelector("[data-docs-article]");
  if (!article) return;
  setSidebarOpen(false);

  if (!slug) {
    article.innerHTML = landingHTML();
    setToc("");
    highlightNav("");
    document.title = "Docs — Zeffiro Interface";
    return;
  }

  try {
    const doc = await loadDoc(slug);
    article.innerHTML = `<article class="docs-article">${doc.html}</article>`;
    setToc(tocHTML(doc.toc, slug));
    highlightNav(slug);
    document.title = `${doc.title} — Zeffiro Docs`;
    typesetMath(article);
    bindTocSpy();
    if (heading) {
      requestAnimationFrame(() => {
        const target = document.getElementById(heading);
        if (target) target.scrollIntoView({ block: "start" });
      });
    } else {
      window.scrollTo({ top: 0, behavior: "instant" });
    }
  } catch {
    article.innerHTML = `<article class="docs-article"><h1>Not found</h1><p>That page is not in the curated documentation set. Start from <a href="docs.html">Docs</a>.</p></article>`;
    setToc("");
  }
}

function bindSearch() {
  const input = document.querySelector("[data-docs-search]");
  const results = document.querySelector("[data-docs-results]");
  if (!input || !results) return;

  const hide = () => {
    results.hidden = true;
    results.innerHTML = "";
  };

  const show = (hits, query) => {
    if (!query.trim()) {
      hide();
      return;
    }
    results.hidden = false;
    if (!hits.length) {
      results.innerHTML = `<p class="docs-results-empty">No matching pages.</p>`;
      return;
    }
    results.innerHTML = hits
      .map(
        (hit) =>
          `<a href="#${hit.slug}"><strong>${hit.title}</strong><span>${hit.snippet || ""}</span></a>`,
      )
      .join("");
  };

  input.addEventListener("focus", () => ensureSearchIndex());
  input.addEventListener("input", async () => {
    await ensureSearchIndex();
    show(searchDocs(input.value), input.value);
  });
  input.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      input.blur();
      hide();
    }
  });
  results.addEventListener("click", hide);
  document.addEventListener("click", (event) => {
    if (!event.target.closest(".docs-search")) hide();
  });
}

function bindChrome() {
  const open = document.querySelector("[data-docs-open]");
  const close = document.querySelector("[data-docs-close]");
  const backdrop = document.querySelector("[data-docs-backdrop]");
  open?.addEventListener("click", () => {
    const page = document.querySelector(".docs-page");
    setSidebarOpen(!page?.classList.contains("is-nav-open"));
  });
  close?.addEventListener("click", () => setSidebarOpen(false));
  backdrop?.addEventListener("click", () => setSidebarOpen(false));

  document.addEventListener("keydown", (event) => {
    if (event.key === "/" && !event.metaKey && !event.ctrlKey && !event.altKey) {
      const tag = event.target?.tagName;
      if (tag === "INPUT" || tag === "TEXTAREA") return;
      event.preventDefault();
      document.querySelector("[data-docs-search]")?.focus();
    }
    if (event.key === "Escape") setSidebarOpen(false);
  });
}

export function initDocs() {
  const nav = document.querySelector("[data-docs-nav]");
  if (nav) nav.innerHTML = navHTML(parseHash().slug);
  bindSearch();
  bindChrome();
  render();
  ensureSearchIndex();
  window.addEventListener("hashchange", render);
}
